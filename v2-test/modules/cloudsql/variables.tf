variable "name_prefix" {
  type        = string
  description = "Prefix for Cloud SQL instances"
}

variable "region" {
  type        = string
  description = "Region for Cloud SQL"
}

variable "tier" {
  type        = string
  default     = "db-custom-1-3840"
  description = "Instance tier (machine type)"
}

variable "network" {
  type        = string
  description = "VPC network self link"
}

variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "db_password" {
  type        = string
  description = "DB password for cafeboo user"
}
