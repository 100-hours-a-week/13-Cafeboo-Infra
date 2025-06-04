variable "vpc_name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr = string
  }))
}
