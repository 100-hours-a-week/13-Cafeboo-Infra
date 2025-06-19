variable "zone" {}
variable "network" {}
variable "subnetwork" {}
variable "service_account_email" {}

variable "loki_url" {
  description = "Loki push endpoint"
}

variable "instance_label" {
  description = "Value for instance label (e.g. dev-private-vm)"
}

variable "job_label" {
  description = "Value for job label (e.g. cafeboo)"
}
