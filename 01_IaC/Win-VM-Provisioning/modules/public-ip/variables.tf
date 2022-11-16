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

variable "publicipname" {
  type        = string
  description = "The name of the public ip address."
}