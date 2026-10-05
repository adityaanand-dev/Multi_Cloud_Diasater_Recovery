output "vm_id" {
  description = "ID of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.app.id
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = azurerm_linux_virtual_machine.app.public_ip_address
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_linux_virtual_machine.app.private_ip_address
}

output "nic_id" {
  description = "ID of the Network Interface"
  value       = azurerm_network_interface.app.id
}
