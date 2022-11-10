output "_vmname" {
  description = "To return the name of the virtual machine"
  value       = azurerm_windows_virtual_machine.windowsvm.name
  sensitive   = false
}