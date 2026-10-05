output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_arns" {
  description = "Map of created CloudWatch alarm ARNs"
  value = {
    alb_unhealthy = aws_cloudwatch_metric_alarm.alb_unhealthy.arn
    rds_cpu       = aws_cloudwatch_metric_alarm.rds_cpu.arn
    asg_instances = aws_cloudwatch_metric_alarm.asg_instances.arn
  }
}
