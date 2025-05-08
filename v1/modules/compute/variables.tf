variable "project" {
  type = string
}

variable "zone" {
  type = string
}

variable "name" {
  description = "VM 인스턴스 이름"
  type        = string
}

variable "machine_type" {
  description = "e2-medium, n1-standard-4 등"
  type        = string
}

variable "image" {
  description = "디스크 이미지 (예: debian-cloud/debian-11)"
  type        = string
}

variable "subnet_self_link" {
  description = "서브넷의 self_link"
  type        = string
}

variable "metadata" {
  description = "startup-script 같은 메타데이터"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "gpu_enabled" {
  type    = bool
  default = false
}

variable "gpu_type" {
  type    = string
  default = "nvidia-tesla-t4"
}

variable "gpu_count" {
  type    = number
  default = 1
}

variable "external_ip" {
  type        = string
  description = "Optional static external IP address"
  default     = null
}
