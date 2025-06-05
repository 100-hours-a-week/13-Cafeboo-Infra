variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "elevated-valve-459107-h8"
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "asia-northeast3"
}

variable "zone" {
  description = "The zone to deploy resources to"
  type        = string
  default     = "asia-northeast3-a"
}
