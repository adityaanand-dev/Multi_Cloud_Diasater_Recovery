output "lb_public_ip" {
  description = "The Public IP address of the Load Balancer"
  value       = azurerm_public_ip.pip.ip_address
}

output "lb_id" {
  description = "The ID of the Load Balancer"
  value       = azurerm_lb.lb.id
}

output "backend_pool_id" {
  description = "The ID of the Backend Address Pool"
  value       = azurerm_lb_backend_address_pool.pool.id
}

output "health_probe_id" {
  description = "The ID of the Health Probe"
  value       = azurerm_lb_probe.probe.id
}
