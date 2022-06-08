variable "environment" {
  type        = string
  description = "The ALM environment (dev, test, prod) for the windows virtual machine."
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure Region where the Resource would be provisioned."
}

variable "resourcegroupname" {
  type        = string
  description = "The Azure Resource Group Name."
}

variable "vmname" {
  type        = string
  description = "The azure windows virtual machine name."
}

variable "vmsize" {
  type        = string
  description = "The size of the azure windows virtual machine."
}

variable "vmadminusername" {
  type        = string
  description = "The name of the admin user for the azure windows virtual machine."
}

variable "vmadminuserpassword" {
  type        = string
  description = "The password of the admin user for the azure windows virtual machine."
}

variable "vmimagepublisher" {
  type        = string
  description = "The image publisher of the azure windows virtual machine."
}

variable "vmimageoffer" {
  type        = string
  description = "The image offer of the azure windows virtual machine."
}

variable "vmimagesku" {
  type        = string
  description = "The image sku of the azure windows virtual machine."
}

variable "vmimageversion" {
  type        = string
  description = "The image version of the azure windows virtual machine."
}

variable "subnetid" {
  type        = string
  default     = ""
  description = "The id of azure SubNet."
}

variable "networkinterfacename" {
  type        = string
  description = "The name of azure network interface card name."
}

variable "networkinterfaceid" {
  type        = string
  description = "The id of azure network interface card."
}

variable "vmosdiskcaching" {
  type        = string
  description = "The type of caching for VM OS disk."
}

variable "vmosdiskstorageaccounttype" {
  type        = string
  description = "The storage account type of the vm os disk."
}