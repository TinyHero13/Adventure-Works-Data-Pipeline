variable "databricks_host" {
  description = "Databricks workspace url"
  type        = string
}

variable "databricks_token" {
  description = "Databricks access token"
  type        = string
  sensitive   = true
}
