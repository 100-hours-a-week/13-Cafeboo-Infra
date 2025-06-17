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
variable "external_ip" {
  description = "External static IP to assign"
  type        = string
}

variable "service_account" {
  description = "Service account to attach to the VM"
  type = object({
    email  = string
    scopes = list(string)
  })
}


