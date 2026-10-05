output "primary_health_check_id" {
  description = "The ID of the primary health check"
  value       = aws_route53_health_check.primary.id
}

output "secondary_health_check_id" {
  description = "The ID of the secondary health check"
  value       = aws_route53_health_check.secondary.id
}

output "primary_dns_record" {
  description = "The name of the primary DNS record"
  value       = aws_route53_record.primary.name
}

output "secondary_dns_record" {
  description = "The name of the secondary DNS record"
  value       = aws_route53_record.secondary.name
}
