variable "name" {}
variable "project" {}
variable "region" {}
variable "network_self_link" {}
variable "subnet_self_link" {}
variable "instance_group_a" {}
variable "ip_address" {
  description = "Static internal IP address for the ILB"
  type        = string
}
