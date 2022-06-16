variable "applicationname" {
  type        = string
  description = "The name of the application."
}

variable "increment" {
  type        = string
  description = "The increment number to be postfixed in the resource name."
}

variable "environment" {
  type        = string
  description = "The ALM environment (dev, test, prod) in which resources are beign deployed."
}

variable "location" {
  type        = string
  description = "The azure region where the resource would be provisioned."
}

variable "locationacronym" {
  type        = string
  description = "The short name of azure region where the resource would be provisioned."
}

variable "resourcegroupname" {
  type        = string
  description = "The azure resource group name in which windows virtual machine would be provisioned."
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

variable "vmosdiskcaching" {
  type        = string
  description = "The type of caching for VM OS disk."
}

variable "vmosdiskstorageaccounttype" {
  type        = string
  description = "The storage account type of the vm os disk."
}

variable "storageaccountname" {
  type        = string
  description = "The name of azure storage Account in which terraform state files would be stored."
}

variable "storageaccounttier" {
  type        = string
  description = "The tier of azure storage Account in which terraform state files would be stored."
}

variable "storageaccountreplicationtype" {
  type        = string
  description = "The replication type of azure storage Account in which terraform state files would be stored."
}

variable "containername" {
  type        = string
  description = "The name of azure storage Container."
}

variable "containeraccesstype" {
  type        = string
  description = "The name of azure storage Container."
}

variable "vnetname" {
  type        = string
  description = "The name of azure Virtual Network."
}

variable "vnetaddressspace" {
  type        = string
  description = "The virtual network address space."
}

variable "subnetname" {
  type        = string
  description = "The name of azure SubNet."
}

variable "subnetid" {
  type        = string
  default     = ""
  description = "The id of azure SubNet."
}

variable "subnetaddressspace" {
  type        = string
  description = "The subnet address space."
}

variable "networkinterfacename" {
  type        = string
  description = "The name of azure network interface card."
}

variable "networkinterfaceid" {
  type        = string
  description = "The id of azure network interface card."
}

variable "nsgname" {
  type        = string
  description = "The name of azure Network Security Group."
}

variable "nsgid" {
  type        = string
  description = "The id of azure Network Security Group."
}

variable "publicipname" {
  type        = string
  description = "The name of the public ip address."
}

variable "publicipid" {
  type        = string
  description = "The id of the public ip address."
}