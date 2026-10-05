output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "action_group_id" {
  description = "The ID of the Action Group"
  value       = azurerm_monitor_action_group.ag.id
}
