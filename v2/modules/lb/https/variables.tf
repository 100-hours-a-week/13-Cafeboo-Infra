variable "name" {
  description = "Name prefix for the HTTPS Load Balancer"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket to serve as the backend"
  type        = string
}

variable "domain" {
  description = "Domain name for HTTPS certificate"
  type        = string
}

variable "backend_health_check" {
  description = "Health check self_link for backend service"
  type        = string
}

variable "backend_instance_group" {
  description = "Self link of backend MIG instance group"
  type        = string
}
