/*
    .SYNOPSIS
        Create and configure the windows virtual machine 2019

    .DESCRIPTION
        Create and configure the windows virtual machine 2019

    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 17 May 2022
        Modified By: Anil Kumar
        Modified Date: 18 May 2022
*/

resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                = var.vmname
  location            = var.location
  resource_group_name = var.resourcegroupname
  size                = var.vmsize
  admin_username      = var.vmadminusername
  admin_password      = var.vmadminuserpassword 
  network_interface_ids = [
    var.networkinterfaceid
  ]

  os_disk {
    caching              = var.vmosdiskcaching
    storage_account_type = var.vmosdiskstorageaccounttype
  }

  source_image_reference {
    publisher = var.vmimagepublisher
    offer     = var.vmimageoffer
    sku       = var.vmimagesku
    version   = var.vmimageversion
  }
}
