variable "environment" {
  type        = string
  description = ""
  default     = ""
}

variable "networkinterfaceid" {
  type        = string
  description = "The id of azure network interface card."
}

variable "nsgid" {
  type        = string
  description = "The id of azure Network Security Group."
}