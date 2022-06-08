/*
    .SYNOPSIS
        Create and configure the network interface resource

    .DESCRIPTION
        Create and configure the network interface resource

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 17 May 2022
        Modified By: Anil Kumar
        Modified Date: 17 May 2022
*/

resource "azurerm_network_interface" "nic" {
  name                = var.networkinterfacename
  location            = var.location
  resource_group_name = var.resourcegroupname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnetid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.publicipid
  }
}

