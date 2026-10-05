output "resource_group_name" {
  description = "The Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = azurerm_subnet.private[*].id
}

output "nsg_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}
