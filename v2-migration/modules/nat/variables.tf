variable "name" {
  description = "Prefix name for the NAT gateway and router"
  type        = string
}

variable "region" {
  description = "Region of the NAT gateway"
  type        = string
}

variable "project" {
  description = "GCP Project ID"
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link"
  type        = string
}

variable "subnetwork_name" {
  description = "NAT 대상 서브넷 이름 (name만, self_link 아님)"
  type        = string
}