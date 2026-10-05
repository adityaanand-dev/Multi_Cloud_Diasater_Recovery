variable "vpc_id" {
  description = "VPC ID where the database will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID of the application to allow access from"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "drapp"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "15"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "multicloud-dr"
}
