/*
    .SYNOPSIS
        Create public IP resource

    .DESCRIPTION
        Create public IP resource

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 June 2022
        Modified By: Anil Kumar
        Modified Date: 16 June 2022
*/

resource "azurerm_public_ip" "publicip" {
  name                = var.publicipname
  location            = var.location
  resource_group_name = var.resourcegroupname
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
}

