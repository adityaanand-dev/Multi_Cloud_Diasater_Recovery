variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "multicloud-dr"
}

variable "db_username" {
  description = "Database username to store in Secrets Manager"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database password to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name to store in Secrets Manager"
  type        = string
  default     = "drapp"
}
