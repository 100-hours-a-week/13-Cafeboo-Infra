variable "name" {}
variable "project" {}
variable "zone" {}
variable "machine_type" {}
variable "image" {}
variable "subnet_self_link" {}
variable "startup_script" { default = "" }
variable "tags" { type = list(string) }
variable "metadata" {
  type    = map(string)
  default = {}
}
