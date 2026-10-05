variable "domain_name" {
  description = "The domain name for the failover record"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
}

variable "aws_endpoint" {
  description = "The AWS endpoint (ALB DNS name or IP)"
  type        = string
}

variable "azure_endpoint" {
  description = "The Azure endpoint (LB public IP)"
  type        = string
}

variable "aws_alb_zone_id" {
  description = "The zone ID of the AWS ALB for the alias record"
  type        = string
  default     = ""
}

variable "health_check_interval" {
  description = "Health check request interval in seconds"
  type        = number
  default     = 30
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
