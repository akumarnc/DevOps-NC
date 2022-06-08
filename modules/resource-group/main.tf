/*
    .SYNOPSIS
        Define the the module for creating resource group
    .DESCRIPTION
        Define the the module for creating resource group. 
        It can be used for creating resource group for any environment (dev, test, prod)
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 17 May 2022
        Modified By: Anil Kumar
        Modified Date: 17 May 2022
*/

# Create the resource group for hosting Windows Virtual machine and it's resources
resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroupname
  location = var.location
}