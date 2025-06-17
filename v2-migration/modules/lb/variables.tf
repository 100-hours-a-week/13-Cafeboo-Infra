variable "name" {
  description = "로드 밸런서 이름"
  type        = string
}

variable "project" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "zone" {
  description = "인스턴스가 있는 존"
  type        = string
}

variable "vm_self_link" {
  description = "백엔드 VM 인스턴스의 self_link"
  type        = string
}

variable "lb_ip_name" {
  description = "로드 밸런서의 글로벌 IP 주소 이름"
  type        = string
  default     = "dev-lb"
}

variable "frontend_bucket_name" {
  description = "프론트엔드 정적 파일이 들어있는 GCS 버킷 이름"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}