import os
from datetime import datetime
from pathlib import Path
from airflow.decorators import dag
from airflow.models import Variable
from cosmos.profiles import DatabricksTokenProfileMapping
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
from cosmos.operators import DbtDocsOperator

DBT_PROJECT_PATH = Path(f"{os.environ.get('AIRFLOW_HOME', '/usr/local/airflow')}/dags/dbt/aw_transform")

def get_profile_config():
    """Create profile config - called only when DAG runs, not during import"""
    return ProfileConfig(
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
    schedule="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    default_args={"retries": 2},
    tags=["dbt", "databricks", "aw"],
)
def aw_transform_dag():
    """
    DAG for running dbt transformations for Adventure Works
    """
    profile_config = get_profile_config()
    
    dbt_tg = DbtTaskGroup(
        group_id="aw_transform",
        project_config=ProjectConfig(
            dbt_project_path=DBT_PROJECT_PATH,
        ),
        profile_config=profile_config,
        operator_args={
            "install_deps": True,
            "full_refresh": True
        },
    )
    
    generate_dbt_docs = DbtDocsOperator(
        task_id="generate_dbt_docs",
        project_dir=str(DBT_PROJECT_PATH),
        profile_config=profile_config,
    )
    
    dbt_tg >> generate_dbt_docs

dag_instance = aw_transform_dag()
