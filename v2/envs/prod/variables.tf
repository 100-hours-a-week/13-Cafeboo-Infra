variable "project" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "elevated-valve-459107-h8"
}

variable "region" {
  type        = string
  description = "GCP 리전"
  default     = "asia-northeast3"
}

variable "zone_A" {
  type        = string
  description = "GCP 존"
  default     = "asia-northeast3-a"
}

variable "zone_B" {
  type        = string
  description = "GCP 존"
  default     = "asia-northeast3-b"
}
