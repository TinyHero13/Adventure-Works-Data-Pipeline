"""AW Database Data Ingestion Pipeline."""
from concurrent.futures import ThreadPoolExecutor
from pyspark.sql import DataFrame

# COMMAND ----------

PATH_OUTPUT = dbutils.secrets.get(scope="app-credentials", key="PATH_TABLE_OUTPUT")
JDBC_URL = dbutils.secrets.get(scope="app-credentials", key="DB_URL")
CONNECTION_PROPERTIES = {
    "user": dbutils.secrets.get(scope="app-credentials", key="DB_USER"),
    "password": dbutils.secrets.get(scope="app-credentials", key="DB_PASSWORD"),
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

MAX_WORKERS = 15
EXCLUDED_SCHEMAS = ['dbo', 'sys', 'information_schema']
TABLE_PREFIX = 'raw_db'

# COMMAND ----------

def get_all_db_tables() -> DataFrame:
    """
    Get all tables from the database
        
    Returns:
        DataFrame: Spark DataFrame containing TABLE_NAME and TABLE_SCHEMA columns
    """

    excluded_schemas_str = "', '".join(EXCLUDED_SCHEMAS)
    query = f"""SELECT
        TABLE_NAME, 
        TABLE_SCHEMA 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE' 
    AND TABLE_SCHEMA NOT IN ('{excluded_schemas_str}')"""
    df = spark.read.jdbc(
        url=JDBC_URL,
        table=f"({query}) as tables",
        properties=CONNECTION_PROPERTIES)
    return df

def extract_table(schema, table) -> DataFrame:
    """
    Extract a specified table from the database
    
    Args:
        schema: The schema name of the table
        table: The table name to extract
        
    Returns:
        DataFrame: Spark DataFrame with table data
        
    Raises:
        RuntimeError: If extraction fails
    """

    try:
        df = spark.read.jdbc(
            url=JDBC_URL,
            table=f"{schema}.{table}",
            properties=CONNECTION_PROPERTIES)
        return df

    except Exception as e: 
        raise RuntimeError(f"Error to extract {schema}.{table}: {e}") from e

def save_table(df, schema, table) -> None:
    """
    Save the DataFrame as a Delta Lake table on Databricks
    
    Args:
        df: Spark DataFrame to save
        schema: Source schema name for table naming
        table: Source table name for table naming
        
    Raises:
        RuntimeError: If save operation fails
    """

    try:
        df.write.format("delta").mode('overwrite').saveAsTable(
            f'{PATH_OUTPUT}.{TABLE_PREFIX}_{schema}_{table}')
    except Exception as e:
        raise RuntimeError(f"Error to save {schema}.{table}: {e}") from e

def process_single_table(schema, table) -> str:
    """
    Process a single table by extracting and saving it as Delta Lake
    
    Args:
        schema: The schema name of the table to process
        table: The table name to process
        
    Returns:
        str: Status message indicating success or failure of the operation
    
    Raises:
        RuntimeError: If any error occurs during extraction or saving
    """

    try:
        df = extract_table(schema, table)
        save_table(df, schema, table)
        return f'Extraction complete for {schema}.{table}'

    except RuntimeError as e:
        return f"Error {schema}.{table}: {e}"

def el_tables_db() -> None:
    """
    Main function to run all the pipeline

    """

    tables_df = get_all_db_tables()
    total_tables = tables_df.count()

    print(f'Total tables: {total_tables}')

    with ThreadPoolExecutor(max_workers=15) as executor:
        futures = [
            executor.submit(process_single_table, row.TABLE_SCHEMA, row.TABLE_NAME)
            for row in tables_df.collect()
        ]
        for future in futures:
            result = future.result()
            print(result)

    print('Migration complete to delta lake')


el_tables_db()