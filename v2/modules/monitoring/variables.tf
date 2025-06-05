variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "host_project_id" {
  description = "The ID of the host project containing the Shared VPC"
  type        = string
}

variable "service_project_id" {
  description = "The ID of the service project where monitoring resources will be created"
  type        = string
}

variable "shared_vpc_name" {
  description = "The name of the Shared VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet in the Shared VPC"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
}

variable "zone" {
  description = "The zone to deploy resources to"
  type        = string
}

variable "instance_name" {
  description = "The name of the monitoring instance"
  type        = string
  default     = "monitoring-instance"
}

variable "machine_type" {
  description = "The machine type for the monitoring instance"
  type        = string
  default     = "e2-medium"
}

variable "disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 50
}

variable "network_tags" {
  description = "Network tags to apply to the instance"
  type        = list(string)
  default     = ["monitoring", "prometheus", "grafana"]
}

variable "monitoring_ports" {
  description = "Ports to allow for monitoring services"
  type        = list(string)
  default     = ["9090", "3000"]
}

variable "allowed_source_ranges" {
  description = "CIDR ranges allowed to access monitoring services"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "be_service_name" {
  description = "Name pattern for BE instances"
  type        = string
  default     = "^be-.*"
}

variable "ai_service_name" {
  description = "Name pattern for AI instances"
  type        = string
  default     = "^ai-.*"
}
