variable "public_subnets" {
  description = "Map of AZ → public subnet ID"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of AZ → private subnet ID"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
