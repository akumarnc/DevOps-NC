/*
    .SYNOPSIS
        Associates the network interface card (nic) with network security group (nsg)

    .DESCRIPTION
        Associates the network interface card (nic) with network security group (nsg)

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 June 2022
        Modified By: Anil Kumar
        Modified Date: 16 June 2022
*/

resource "azurerm_network_interface_security_group_association" "associate-nic-nsg" {
  network_interface_id      = var.networkinterfaceid
  network_security_group_id = var.nsgid
}

