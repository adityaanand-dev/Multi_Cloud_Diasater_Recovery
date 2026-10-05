# AWS endpoint health check (Primary)
resource "aws_route53_health_check" "primary" {
  fqdn              = var.aws_endpoint
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = var.health_check_interval

  tags = {
    Name        = "${var.project_name}-${var.environment}-primary-hc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Azure endpoint health check (Secondary)
resource "aws_route53_health_check" "secondary" {
  ip_address        = var.azure_endpoint
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = var.health_check_interval

  tags = {
    Name        = "${var.project_name}-${var.environment}-secondary-hc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Primary DNS Record
# Configured with failover routing. When the AWS health check fails, 
# DNS automatically routes traffic to the Azure secondary endpoint.
resource "aws_route53_record" "primary" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  
  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  health_check_id = aws_route53_health_check.primary.id
  
  alias {
    name                   = var.aws_endpoint
    zone_id                = var.aws_alb_zone_id
    evaluate_target_health = true
  }
}

# Secondary DNS Record (Azure fallback)
# Automatically utilized when the AWS primary health check fails.
resource "aws_route53_record" "secondary" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  
  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  health_check_id = aws_route53_health_check.secondary.id
  ttl             = 60
  records         = [var.azure_endpoint]
}
