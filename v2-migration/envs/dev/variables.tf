variable "project" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "true-alliance-464905-t8"
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
  default     = "projects/true-alliance-464905-t8/locations/global/hubs/v2-shared-hub"
}

variable "external_ip" {
  description = "Optional static external IP address"
  type        = string
  default = "null"
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
}




