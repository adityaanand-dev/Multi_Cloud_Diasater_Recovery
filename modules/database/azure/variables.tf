variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources should be created"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network"
  type        = string
}

variable "delegated_subnet_id" {
  description = "The ID of the delegated subnet for the PostgreSQL Flexible Server"
  type        = string
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "drapp"
}

variable "admin_username" {
  description = "The Administrator Login for the PostgreSQL Flexible Server"
  type        = string
  default     = "dbadmin"
}

variable "admin_password" {
  description = "The Password associated with the administrator_login"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server in MB"
  type        = number
  default     = 32768
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
