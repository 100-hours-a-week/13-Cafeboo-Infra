variable "project" {
  description = "The ID of the GCP project"
  type        = string
  default     = "cafeboo-459107"
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
