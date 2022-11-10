/*
    .SYNOPSIS
        Create and configure the Network Security Group

    .DESCRIPTION
        Create and configure the Network Security Group

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 June 2022
        Modified By: Anil Kumar
        Modified Date: 16 June 2022
*/

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsgname
  location            = var.location
  resource_group_name = var.resourcegroupname

  tags = {
    environment = var.environment
  }
}

