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