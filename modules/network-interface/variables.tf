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

variable "subnetid" {
  type        = string
  default     = ""
  description = "The id of azure SubNet."
}

variable "networkinterfacename" {
  type        = string
  description = "The name of azure network interface card name."
}

variable "publicipid" {
  type        = string
  description = "The id of the public ip address."
}
