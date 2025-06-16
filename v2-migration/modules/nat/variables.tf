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

variable "subnetworks" {
  type = list(object({
    name                    = string
    source_ip_ranges_to_nat = list(string)
  }))
  description = "List of subnetworks to apply NAT to"
}
