/*
    .SYNOPSIS
        Configure the Azure provider, Provider version and Terraform backend setup for Windows Virtual Machine 2019 provisioning.
    .DESCRIPTION
        This is the main file which performs below:
        a.) Defines the cloud resource provider
        b.) Terraform backend setup
        c.) Code to call modules for provisioning Windows Virtual Machine 2019 Datacenter
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 June 2022
        Modified By: Anil Kumar
        Modified Date: 16 June 2022
*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  required_version = ">= 0.14.9"

  # Backend setup to maintain Terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-terraformstate"
    storage_account_name = "stvmprovisioning"
    container_name       = "win-vm-provisioning"
    key                  = "winvm2019.tfstate"
  }
}

# Azure Cloud Provider name
provider "azurerm" {
  features {}
}

# Call resource group module 
module "resourcegroup" {
  source = "./modules/resource-group"

  resourcegroupname = "${var.resourcegroupname}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  location          = var.location
}

# Call Virtual Network module
module "virtualnetwork" {
  source = "./modules/virtual-network"

  vnetname          = "${var.vnetname}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  vnetaddressspace  = var.vnetaddressspace
  location          = module.resourcegroup._resourcegrouplocation
  resourcegroupname = module.resourcegroup._resourcegroupname
}

# Call Subnet module
module "subnet" {
  source = "./modules/subnet"

  subnetname         = "${var.subnetname}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  subnetaddressspace = var.subnetaddressspace
  vnetname           = module.virtualnetwork._vnetname
  location           = module.resourcegroup._resourcegrouplocation
  resourcegroupname  = module.resourcegroup._resourcegroupname
}

# Call Public IP module
module "publicip" {
  source = "./modules/public-ip"

  publicipname      = "${var.publicipname}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  location          = module.resourcegroup._resourcegrouplocation
  resourcegroupname = module.resourcegroup._resourcegroupname
  environment       = var.environment
}

# Call Network Interface module
module "networkinterface" {
  source = "./modules/network-interface"

  networkinterfacename = "${var.networkinterfacename}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  subnetid             = module.subnet._subnetid
  location             = module.resourcegroup._resourcegrouplocation
  resourcegroupname    = module.resourcegroup._resourcegroupname
  publicipid           = module.publicip._publicipid
}

# Call Network Security Group module
module "networksecuritygroup" {
  source = "./modules/network-security-group"

  nsgname           = "${var.nsgname}-${var.applicationname}-${var.environment}-${var.locationacronym}-${var.increment}"
  location          = module.resourcegroup._resourcegrouplocation
  resourcegroupname = module.resourcegroup._resourcegroupname
  environment       = var.environment
}

# Call the module to associate network interface with network security group
module "associatenicnsg" {
  source = "./modules/associate-nic-nsg"

  networkinterfaceid = module.networkinterface._networkinterfaceid
  nsgid              = module.networksecuritygroup._networksecuritygroupid
}

# Call Windows Virtual Machine module
module "virtualmachine-windows" {
  source = "./modules/vm-windows"

  vmname                     = "${var.vmname}${var.applicationname}${var.environment}${var.locationacronym}${var.increment}"
  location                   = module.resourcegroup._resourcegrouplocation
  resourcegroupname          = module.resourcegroup._resourcegroupname
  networkinterfacename       = var.networkinterfacename
  networkinterfaceid         = module.networkinterface._networkinterfaceid
  vmsize                     = var.vmsize
  vmadminusername            = var.vmadminusername
  vmimagepublisher           = var.vmimagepublisher
  vmimageoffer               = var.vmimageoffer
  vmimagesku                 = var.vmimagesku
  vmimageversion             = var.vmimageversion
  vmosdiskcaching            = var.vmosdiskcaching
  vmosdiskstorageaccounttype = var.vmosdiskstorageaccounttype

}