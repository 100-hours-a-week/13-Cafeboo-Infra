variable "project" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "cafeboo-459107"
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

variable "image" {
  type        = string
  description = "공통적으로 사용할 기본 VM 이미지"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "ssh_public_key" {
  description = "SSH public key to access prod instances"
  type        = string
}

variable "db_password" {
  description = "Cloud SQL 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  type      = string
  sensitive = true
}
