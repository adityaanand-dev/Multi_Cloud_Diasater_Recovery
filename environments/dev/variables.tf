# =============================================================================
# Variables - Development Environment
# =============================================================================

# --- General ---
variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "multicloud-dr"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
}

# --- AWS Configuration ---
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0dee22c13ea7a9a67" # Ubuntu 22.04 ap-south-1
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_key_name" {
  description = "AWS SSH key pair name"
  type        = string
}

# --- Azure Configuration ---
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "azure_admin_password" {
  description = "Azure VM admin password"
  type        = string
  sensitive   = true
}

# --- Database Configuration ---
variable "db_name" {
  description = "Database name (used on both clouds)"
  type        = string
  default     = "drapp"
}

variable "db_username" {
  description = "Database admin username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

# --- DNS (Optional) ---
# variable "domain_name" {
#   description = "Domain name for DNS failover"
#   type        = string
# }
#
# variable "hosted_zone_id" {
#   description = "Route53 hosted zone ID"
#   type        = string
# }
