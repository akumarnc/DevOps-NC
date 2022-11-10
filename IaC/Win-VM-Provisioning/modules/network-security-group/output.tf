output "_networksecuritygroupid" {
  description = "To return the id of the network security group"
  value       = azurerm_network_security_group.nsg.id
  sensitive   = false
}