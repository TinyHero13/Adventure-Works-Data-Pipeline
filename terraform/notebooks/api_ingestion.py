"""AW API Data Ingestion Pipeline."""
import json
import re
import time
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, Any
import requests
from pyspark.sql.functions import schema_of_json, lit
from pyspark.sql.functions import from_json
from pyspark.sql import DataFrame

# COMMAND ----------

PATH_OUTPUT = dbutils.secrets.get(
    scope="app-credentials",
    key="PATH_TABLE_OUTPUT")
URL = dbutils.secrets.get(scope="app-credentials", key="API_URL")
USER = dbutils.secrets.get(scope="app-credentials", key="API_USER")
PASSWORD = dbutils.secrets.get(scope="app-credentials", key="API_PASSWORD")

MAX_WORKERS = 10
BATCH_SIZE = 100000
DEFAULT_LIMIT = 5
MAX_RETRIES = 10
TABLE_PREFIX = 'raw_api'
ENDPOINTS = [
    'SalesOrderHeader',
    'PurchaseOrderDetail',
    'PurchaseOrderHeader',
    'SalesOrderDetail'
]

# COMMAND ----------


def extract_date_fields(rows_api) -> set:
    """
    Extract date fields from API response rows by analyzing string patterns
    
    Args:
        rows_api: List of dictionaries containing API response data
        
    Returns:
        set: Set of field names that contain datetime strings
    """
    date_fields = set()
    for row in rows_api:
        for key, value in row.items():
            if isinstance(value, str) and re.match(
                    r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}', value):
                date_fields.add(key)
    return date_fields


def analyze_field_types(rows_api):
    """
    Analyze field types from API response rows using Spark schema detection

    Args:
        rows_api: List of dictionaries containing API response data

    Returns:
        dict: Dictionary mapping field names to their detected data types

    """
    field_types = {}
    for i, row in enumerate(rows_api):
        if not row:
            continue
        try:
            row_json = json.dumps(row)
            row_schema = schema_of_json(lit(row_json))
            schema_df = spark.range(1).select(row_schema.alias("schema"))
            schema_string = schema_df.collect()[0]['schema']
            field_pattern = r'(\w+):\s*(\w+)'
            matches = re.findall(field_pattern, schema_string)

            for field_name, field_type in matches:
                if field_name not in field_types:
                    field_types[field_name] = field_type
                elif (field_types[field_name] == 'STRING' and
                      field_type != 'STRING'):
                    field_types[field_name] = field_type
                elif field_type not in ('STRING', field_types[field_name]):
                    if 'DOUBLE' in (field_type, field_types[field_name]):
                        field_types[field_name] = 'DOUBLE'
                    elif (field_type in ['BIGINT', 'LONG'] or
                          field_types[field_name] in ['BIGINT', 'LONG']):
                        field_types[field_name] = 'BIGINT'

        except Exception as e:
            print(f'Error processing row {i}: {e}')
            continue
    return field_types

def build_final_schema(rows_api, field_types, date_fields):
    """
    Build the final schema string by combining base schema with detected types

    Args:
        rows_api: List of dictionaries containing API response data
        field_types: Dictionary mapping field names to detected types
        date_fields: Set of field names containing datetime values

    Returns:
        str: Final optimized schema string for DataFrame creation

    """
    first_row = json.dumps(rows_api[0])
    json_schema = schema_of_json(lit(first_row))
    base_schema_df = spark.range(1).select(
        json_schema.alias("base_schema"))
    base_schema_string = base_schema_df.collect()[0]['base_schema']
    final_schema = base_schema_string

    for field, detected_type in field_types.items():
        if detected_type != 'STRING':
            old_pattern = f"{field}: STRING"
            new_pattern = f"{field}: {detected_type}"
            if old_pattern in final_schema:
                final_schema = final_schema.replace(
                    old_pattern, new_pattern)

    if date_fields:
        for date_field in date_fields:
            old_pattern = f"{date_field}: STRING"
            new_pattern = f"{date_field}: TIMESTAMP"
            if old_pattern in final_schema:
                final_schema = final_schema.replace(
                    old_pattern, new_pattern)

    return final_schema


def get_schema_api(response_data, rows=5) -> str:
    """
    Get the schema from the api, make treatments for date/datetime types

    Args:
        response_data: List of dictionaries containing API response data
        rows: Number of rows to analyze for schema detection

    Returns:
        str: Optimized Spark schema string with proper data types

    Raises:
        Exception: If schema extraction fails
    """
    try:
        rows_api = response_data[:rows]
        date_fields = extract_date_fields(rows_api)
        field_types = analyze_field_types(rows_api)
        final_schema = build_final_schema(rows_api, field_types, date_fields)
        return final_schema

    except Exception as e:
        print(f'Error getting schema: {e}')
        raise RuntimeError(f'Failed to get schema: {e}') from e


def get_api_data(endpoint, offset, limit) -> Dict[str, Any]:
    """
    Get data from an endpoint

    Args:
        endpoint: API endpoint
        offset: Pagination offset
        limit: Number of records per page

    Returns:
        dict: JSON data from API or None if error

    Raises:
        TimeoutError or ConnectionError: If request fails or times out
    """
    print(f'Extracting {endpoint} - offset: {offset}')
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = requests.get(
                URL + endpoint,
                params={'offset': offset, 'limit': limit},
                auth=(USER, PASSWORD),
                timeout=(5, 15)
            )
            response.raise_for_status()
            print(f'{endpoint} - {offset} completed')
            return response.json()

        except (requests.exceptions.ConnectTimeout,
                requests.exceptions.ReadTimeout,
                requests.exceptions.Timeout) as e:

            print(f'Timeout for {endpoint} - {attempt}/{MAX_RETRIES}: {e}')
            if attempt < MAX_RETRIES:
                time.sleep(5)
                continue
            raise TimeoutError(
                f'Timeout after {MAX_RETRIES} attempts for {endpoint}') from e

        except requests.exceptions.RequestException as e:
            raise ConnectionError(
                f'Request failed for {endpoint} offset {offset}: {e}') from e
    raise RuntimeError(f'Unexpected error getting data from {endpoint}')


def create_spark_df(results, schema_df) -> DataFrame:
    """
    Create spark dataframe with the schema

    Args:
        results: List of dictionaries containing API response data
        schema_df: Schema string or DataFrame for the Spark DataFrame

    Returns:
        DataFrame: Spark DataFrame with the data from API responses

    Raises:
        ValueError: If DataFrame creation fails
    """
    try:
        all_data = []
        for result in results:
            if 'data' in result and result['data']:
                all_data.extend(result['data'])

        if isinstance(schema_df, str):
            json_strings = [json.dumps(row) for row in all_data]
            temp_df = spark.createDataFrame(
                [(s,) for s in json_strings], ["json_str"])

            df = temp_df.select(
                from_json(
                    "json_str",
                    schema_df).alias("data")).select("data.*")
            return df

        df = spark.createDataFrame(all_data)
        return df

    except ValueError as e:
        raise ValueError(f'Error creating dataframe: {e}') from e


def save_df(df, endpoint_name) -> None:
    """
    Save the DataFrame as Delta Lake table on Databricks

    Args:
        df: Spark DataFrame to save
        endpoint_name: Endpoint name for table naming

    Raises:
        RuntimeError: If save operation fails
    """
    try:
        df.write \
            .mode("overwrite") \
            .saveAsTable(f'{PATH_OUTPUT}.{TABLE_PREFIX}_{endpoint_name}')

        print(f'Delta lake created for {endpoint_name}')
    except RuntimeError as e:
        raise RuntimeError(
            f'Error saving dataframe for {endpoint_name}: {e}') from e


def process_endpoint(endpoint_name) -> None:
    """
    Process a complete endpoint, extract schema, get data, and save as Delta table

    Args:
        endpoint_name: API endpoint name to process

    Raises:
        RuntimeError: If any error occurs during processing
    """
    print(f'Extracting data from {endpoint_name}')
    try:
        response = get_api_data(endpoint_name, 0, DEFAULT_LIMIT)
        schema_json = get_schema_api(response['data'])

        total_rows = response['total']
        offsets = list(range(0, total_rows, BATCH_SIZE))

        api_data = []
        for offset in offsets:
            data = get_api_data(endpoint_name, offset, BATCH_SIZE)
            api_data.append(data)

        if api_data:
            df = create_spark_df(api_data, schema_json)
            save_df(df, endpoint_name)
    except RuntimeError as e:
        raise RuntimeError(f'Error processing endpoint {endpoint_name}: {e}') from e


def el_data_api() -> None:
    """
    Main function to execute parallel ingestion of all endpoints

    """
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {
            executor.submit(
                process_endpoint,
                endpoint_name): endpoint_name for endpoint_name in ENDPOINTS}
        for future in futures:
            endpoint_name = futures[future]
            try:
                future.result()
            except RuntimeError as e:
                print(f'Failed to process {endpoint_name}: {e}')

el_data_api()