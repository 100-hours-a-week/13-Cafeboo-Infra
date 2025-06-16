variable "project" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "master-isotope-462503-m9"
}

variable "region" {
  type        = string
  description = "GCP 리전"
  default     = "asia-northeast3"
}

variable "zone" {
  type        = string
  description = "GCP 존"
  default     = "asia-northeast3-a"
}

variable "image" {
  type        = string
  description = "공통적으로 사용할 기본 VM 이미지"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "hub_id" {
  description = "The full resource ID of the NCC Hub"
  type        = string
  default     = "projects/master-isotope-462503-m9/locations/global/hubs/v2-shared-hub"
}


