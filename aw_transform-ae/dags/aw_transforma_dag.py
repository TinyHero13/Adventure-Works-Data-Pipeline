import os
from datetime import datetime
from pathlib import Path
from airflow.decorators import dag
from airflow.models import Variable
from cosmos.profiles import DatabricksTokenProfileMapping
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig

DBT_PROJECT_PATH = Path(f"{os.environ.get('AIRFLOW_HOME', '/usr/local/airflow')}/dags/dbt/aw_transform")

profile_config = ProfileConfig(
    profile_name=Variable.get("DBT_PROFILE_NAME"),
    target_name=Variable.get("DBT_TARGET_NAME"),
    profile_mapping=DatabricksTokenProfileMapping(
        conn_id=Variable.get("DATABRICKS_CONNECTION_ID"),
        profile_args={
            "catalog": Variable.get("DATABRICKS_CATALOG"),
            "schema": Variable.get("DATABRICKS_SCHEMA"),
            "host": Variable.get("DATABRICKS_HOST"),
            "http_path": Variable.get("DATABRICKS_HTTP_PATH"),
            "token": Variable.get("DATABRICKS_TOKEN")
        },
    )
)

@dag(
    dag_id="aw_transform_dag",
    schedule="@hourly",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    default_args={"retries": 0},
    tags=["dbt", "databricks", "aw"],
)
def aw_transform_dag():
    """
    DAG for running dbt transformations for Adventure Works
    """
    
    dbt_tg = DbtTaskGroup(
        group_id="aw_transform",
        project_config=ProjectConfig(
            dbt_project_path=DBT_PROJECT_PATH,
        ),
        profile_config=profile_config,
        operator_args={
            "install_deps": True,
            "full_refresh": True,
        },
    )
    
    return dbt_tg

dag_instance = aw_transform_dag()