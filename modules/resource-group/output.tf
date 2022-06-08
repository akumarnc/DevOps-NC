output "_resourcegroupname" {
  description = "To return the name of the resource group"
  value       = azurerm_resource_group.rg.name
  sensitive   = false
}

output "_resourcegrouplocation" {
  description = "To return the location of the resource group"
  value       = azurerm_resource_group.rg.location
  sensitive   = false
}