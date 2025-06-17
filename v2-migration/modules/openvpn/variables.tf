variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "subnet" {
  description = "Self link of the subnet to attach the OpenVPN instance to"
  type        = string
}

variable "static_ip" {
  description = "Static external IP address for the OpenVPN server"
  type        = string
}

variable "instance_name" {
  description = "Name of the OpenVPN instance"
  type        = string
}

variable "startup_script" {
  description = "Path to the OpenVPN install startup script"
  type        = string
}

variable "tags" {
  description = "Network tags to assign to the instance (e.g., for firewall rules)"
  type        = list(string)
}
