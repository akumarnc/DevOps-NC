output "_networkinterfaceid" {
  description = "To return the id of the network interface"
  value       = azurerm_network_interface.nic.id
  sensitive   = false
}