variable "name_prefix" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "startup_script" {
  type = string
}

variable "target_size" {
  type = number
}

variable "health_check" {
  type = string
}

variable "distribution_zones" {
  type        = list(string)
  description = "List of zones to distribute MIG instances across"
}
