variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix for CloudWatch metrics"
  type        = string
}

variable "db_instance_id" {
  description = "RDS DB Instance Identifier"
  type        = string
}

variable "alert_email" {
  description = "Email address for alert subscriptions"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
