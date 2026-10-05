resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.project_name}-${var.environment}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "${var.project_name}-${var.environment}-ag"
  resource_group_name = var.resource_group_name
  short_name          = "dr-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "${var.project_name}-${var.environment}-vm-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Triggered when VM CPU > 80%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_monitor_metric_alert" "availability" {
  name                = "${var.project_name}-${var.environment}-vm-avail"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Triggered when VM availability drops"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
