/*
    .SYNOPSIS
        Create and configure the virtual network resource

    .DESCRIPTION
        Create and configure the virtual network resource

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 June 2022
        Modified By: Anil Kumar
        Modified Date: 16 June 2022
*/

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  address_space       = [var.vnetaddressspace]
  location            = var.location
  resource_group_name = var.resourcegroupname
}

