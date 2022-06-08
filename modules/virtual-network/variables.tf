variable "environment" {
  type        = string
  description = ""
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

variable "vnetname" {
  type        = string
  description = "The Azure Virtual Network name."
}

variable "vnetaddressspace" {
  type        = string
  description = "The Azure Virtual Network address space."
}
