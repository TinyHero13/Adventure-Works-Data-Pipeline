import getpass
import requests
from pyspark.sql.functions import schema_of_json, lit
from pyspark.sql.functions import from_json
import json
import re
import time
from concurrent.futures import ThreadPoolExecutor

path_output = dbutils.secrets.get(scope="app-credentials", key="PATH_OUTPUT")
url = dbutils.secrets.get(scope="app-credentials", key="API_URL") 
user = dbutils.secrets.get(scope="app-credentials", key="API_USER")
password = dbutils.secrets.get(scope="app-credentials", key="API_PASSWORD")

def get_first_rows_api(endpoint, limit=5):
    """Get first rows from an endpoint"""
    try:
        response = requests.get(
            url + endpoint, 
            params={'offset': 0, 'limit': limit}, 
            auth=(user, password)
        )
        return response.json()
    except Exception as e:
        print(f'Error to get response: {e}')
        return None

def get_schema_api(response_data, rows=5):
    """Get the schema from the api, make treatments for date/datetime types and return the schema"""
    try:        
        rows_api = response_data[:rows]

        date_fields = set()
        all_fields = set()
        
        for row in rows_api:
            all_fields.update(row.keys())
            for key, value in row.items():
                if isinstance(value, str) and re.match(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}', value):
                    date_fields.add(key)
        
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
                    elif field_types[field_name] == 'STRING' and field_type != 'STRING':

                        field_types[field_name] = field_type
                    elif field_type != 'STRING' and field_types[field_name] != field_type:

                        if field_type == 'DOUBLE' or field_types[field_name] == 'DOUBLE':
                            field_types[field_name] = 'DOUBLE'
                        elif field_type in ['BIGINT', 'LONG'] or field_types[field_name] in ['BIGINT', 'LONG']:
                            field_types[field_name] = 'BIGINT'
                        
            except Exception as e:
                print(f"Error processing row {i+1}: {e}")
                continue
                
        first_row = json.dumps(rows_api[0])
        json_schema = schema_of_json(lit(first_row))
        
        base_schema_df = spark.range(1).select(json_schema.alias("base_schema"))
        base_schema_string = base_schema_df.collect()[0]['base_schema']
                
        final_schema = base_schema_string
        
        for field, detected_type in field_types.items():
            if detected_type != 'STRING':
                old_pattern = f"{field}: STRING"
                new_pattern = f"{field}: {detected_type}"
                if old_pattern in final_schema:
                    final_schema = final_schema.replace(old_pattern, new_pattern)
        
        if date_fields:
            for date_field in date_fields:
                old_pattern = f"{date_field}: STRING"
                new_pattern = f"{date_field}: TIMESTAMP"
                if old_pattern in final_schema:
                    final_schema = final_schema.replace(old_pattern, new_pattern)
        
        return final_schema
        
    except Exception as e:
        print(f'Error getting schema: {e}')
        return None

def get_api_data(endpoint, offset, limit, max_retries=10):
    """Get all data from an endpoint"""
    print(f'Extracting {endpoint} - offset: {offset}')
    for attempt in range(1, max_retries+1):
        try:
            response = session.get(
                url + endpoint,
                params={'offset': offset, 'limit': limit},
                timeout=(5, 15)  
            )
            response.raise_for_status()
            print(f'{endpoint} - {offset} completed')
            return response.json()

        except (requests.exceptions.ConnectTimeout,
                requests.exceptions.ReadTimeout,
                requests.exceptions.Timeout) as e:

            print(f'Timeout for {endpoint} - {attempt}/{max_retries}: {e}')
            if attempt < max_retries:
                time.sleep(5)
            else:
                return None

        except requests.exceptions.RequestException as e:
            print(f'Error {endpoint} offset {offset}: {e}')
            return None
    return None

def create_spark_df(results, schema_df):
    """Create spark dataframe with the schema"""
    try:
        all_data = []
        for result in results:
            if 'data' in result and result['data']:
                all_data.extend(result['data'])
            
        if isinstance(schema_df, str):
            json_strings = [json.dumps(row) for row in all_data]
            temp_df = spark.createDataFrame([(s,) for s in json_strings], ["json_str"])
            
            df = temp_df.select(from_json("json_str", schema_df).alias("data")).select("data.*")
            return df
        else:
            df = spark.createDataFrame(all_data)
            return df
            
    except Exception as e:
        print(f'Error creating df: {e}')
        return None
    
def save_df(df, endpoint_name):
    """Save the dataframe as delta lake on databricks"""
    df.write \
    .mode("overwrite") \
    .saveAsTable(f'{path_output}.raw_api_{endpoint_name}')

    print(f'Delta lake created for {endpoint_name}')

def process_endpoint(endpoint_name):
    """Process an endpoint, get total, schema, data then saves the dataframe"""
    print(f'Extracting data from {endpoint_name}')
    response = get_first_rows_api(endpoint_name)
    if not response:
        return
        
    schema_json = get_schema_api(response['data'])
    if not schema_json:
        return
    
    total_rows = response['total']
    offsets = list(range(0, total_rows, 100000))
    
    api_data = []
    for offset in offsets:
        data = get_api_data(endpoint_name, offset, 100000)
        if data:
            api_data.append(data)
    
    if api_data:
        df = create_spark_df(api_data, schema_json)
        if df:
            save_df(df, endpoint_name)

def el_data_api():
    """Main function to execute parallelism and process all endpoints"""
    endpoints = [
        'SalesOrderHeader',
        'PurchaseOrderDetail',
        'PurchaseOrderHeader',
        'SalesOrderDetail'
    ]
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(process_endpoint, endpoint_name) for endpoint_name in endpoints]
        for future in futures:
            future.result()

el_data_api()