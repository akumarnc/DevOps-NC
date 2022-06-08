output "_vnetname" {
  description = "To return the name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
  sensitive   = false
}