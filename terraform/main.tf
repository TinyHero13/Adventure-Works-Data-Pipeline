terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host     = var.databricks_host
  token    = var.databricks_token
}

resource "databricks_notebook" "api_ingestion" {
  path     = "${var.output_path}/api_ingestion"
  language = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/api_ingestion.py"))
}