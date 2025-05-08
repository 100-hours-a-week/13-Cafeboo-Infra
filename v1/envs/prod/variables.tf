variable "project" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "hazel-field-457008-j8"
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
  default     = "ubuntu-os-cloud/ubuntu-minimal-2410-oracular-amd64-v20250409"
}
