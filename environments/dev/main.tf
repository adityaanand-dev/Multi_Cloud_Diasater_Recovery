# =============================================================================
# Development Environment - Multi-Cloud DR POC
# Deploys infrastructure to both AWS and Azure
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state configuration
  backend "s3" {
    bucket         = "multicloud-dr-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# =============================================================================
# AWS Infrastructure
# =============================================================================

# --- Networking ---
module "aws_networking" {
  source      = "../../modules/networking/aws"
  environment = var.environment
  aws_region  = var.aws_region
  vpc_cidr    = var.aws_vpc_cidr
}

# --- Security ---
module "aws_security" {
  source      = "../../modules/security/aws"
  environment = var.environment
  db_password = var.db_password
  db_username = var.db_username
  db_name     = var.db_name
}

# --- Load Balancer ---
module "aws_load_balancer" {
  source            = "../../modules/load-balancer/aws"
  vpc_id            = module.aws_networking.vpc_id
  public_subnet_ids = module.aws_networking.public_subnet_ids
  environment       = var.environment
}

# --- Compute (Auto Scaling Group) ---
module "aws_compute" {
  source                    = "../../modules/compute/aws"
  ami_id                    = var.aws_ami_id
  instance_type             = var.aws_instance_type
  key_name                  = var.aws_key_name
  vpc_id                    = module.aws_networking.vpc_id
  subnet_ids                = module.aws_networking.private_subnet_ids
  target_group_arn          = module.aws_load_balancer.target_group_arn
  environment               = var.environment
  iam_instance_profile_name = module.aws_security.instance_profile_name
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
}

# --- Database ---
module "aws_database" {
  source                = "../../modules/database/aws"
  vpc_id                = module.aws_networking.vpc_id
  private_subnet_ids    = module.aws_networking.private_subnet_ids
  app_security_group_id = module.aws_compute.security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  environment           = var.environment
  multi_az              = false # Dev environment
}

# --- Monitoring ---
module "aws_monitoring" {
  source                  = "../../modules/monitoring/aws"
  asg_name                = module.aws_compute.asg_name
  alb_arn_suffix          = module.aws_load_balancer.alb_arn_suffix
  target_group_arn_suffix = module.aws_load_balancer.target_group_arn_suffix
  db_instance_id          = module.aws_database.db_instance_id
  alert_email             = var.alert_email
  environment             = var.environment
}

# =============================================================================
# Azure Infrastructure
# =============================================================================

# --- Networking ---
module "azure_networking" {
  source      = "../../modules/networking/azure"
  environment = var.environment
  location    = var.azure_location
}

# --- Security ---
module "azure_security" {
  source              = "../../modules/security/azure"
  environment         = var.environment
  location            = var.azure_location
  resource_group_name = module.azure_networking.resource_group_name
  db_password         = var.db_password
  db_username         = var.db_username
}

# --- Compute ---
module "azure_compute" {
  source              = "../../modules/compute/azure"
  vm_size             = var.azure_vm_size
  location            = var.azure_location
  resource_group_name = module.azure_networking.resource_group_name
  subnet_id           = module.azure_networking.public_subnet_ids[0]
  nsg_id              = module.azure_networking.nsg_id
  environment         = var.environment
  admin_password      = var.azure_admin_password
}

# --- Database ---
module "azure_database" {
  source              = "../../modules/database/azure"
  resource_group_name = module.azure_networking.resource_group_name
  location            = var.azure_location
  vnet_id             = module.azure_networking.vnet_id
  delegated_subnet_id = module.azure_networking.private_subnet_ids[0]
  db_name             = var.db_name
  admin_username      = var.db_username
  admin_password      = var.db_password
  environment         = var.environment
}

# --- Monitoring ---
module "azure_monitoring" {
  source              = "../../modules/monitoring/azure"
  resource_group_name = module.azure_networking.resource_group_name
  location            = var.azure_location
  vm_id               = module.azure_compute.vm_id
  alert_email         = var.alert_email
  environment         = var.environment
}

# =============================================================================
# Cross-Cloud: DNS Failover (Optional - requires Route53 hosted zone)
# =============================================================================

# module "dns_failover" {
#   source          = "../../modules/dns-failover"
#   domain_name     = var.domain_name
#   hosted_zone_id  = var.hosted_zone_id
#   aws_endpoint    = module.aws_load_balancer.alb_dns_name
#   azure_endpoint  = module.azure_compute.public_ip_address
#   aws_alb_zone_id = module.aws_load_balancer.alb_zone_id
#   environment     = var.environment
# }
