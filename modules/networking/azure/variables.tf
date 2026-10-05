variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "centralindia"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multicloud-dr"
}
