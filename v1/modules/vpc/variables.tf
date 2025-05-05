variable "project" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전 (예: asia-northeast3)"
  type        = string
}

variable "vpc_name" {
  description = "생성할 VPC 이름"
  type        = string
  default     = "main-vpc"
}

variable "public_subnet_cidr" {
  description = "Public 서브넷의 CIDR 블록"
  type        = string
  default     = "10.0.0.0/24"
}
