variable "name" {}
variable "project" {}
variable "region" {}
variable "zone" {}
variable "machine_type" {}
variable "image" {}
variable "subnet_self_link" {}
variable "startup_script" {
  type      = string
  default   = ""
  sensitive = true
}
variable "tags" { type = list(string) }
variable "metadata" {
  type    = map(string)
  default = {}
}
