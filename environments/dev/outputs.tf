# =============================================================================
# Outputs - Development Environment
# =============================================================================

# --- AWS Outputs ---
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_networking.vpc_id
}

output "aws_alb_dns" {
  description = "AWS Application Load Balancer DNS name"
  value       = module.aws_load_balancer.alb_dns_name
}

output "aws_db_endpoint" {
  description = "AWS RDS endpoint"
  value       = module.aws_database.db_endpoint
  sensitive   = true
}

# --- Azure Outputs ---
output "azure_resource_group" {
  description = "Azure Resource Group name"
  value       = module.azure_networking.resource_group_name
}

output "azure_vm_public_ip" {
  description = "Azure VM public IP"
  value       = module.azure_compute.public_ip_address
}

output "azure_db_fqdn" {
  description = "Azure PostgreSQL server FQDN"
  value       = module.azure_database.server_fqdn
  sensitive   = true
}

# --- Cross-Cloud Summary ---
output "deployment_summary" {
  description = "Summary of multi-cloud deployment"
  value = {
    aws_primary_url   = "http://${module.aws_load_balancer.alb_dns_name}"
    azure_standby_url = "http://${module.azure_compute.public_ip_address}"
    environment       = var.environment
    aws_region        = var.aws_region
    azure_location    = var.azure_location
  }
}
