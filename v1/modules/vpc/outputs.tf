output "vpc_name" {
  description = "VPC 이름"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "VPC self_link (참조용)"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "Public Subnet 이름"
  value       = google_compute_subnetwork.public_subnet.name
}

output "subnet_self_link" {
  description = "Public Subnet self_link"
  value       = google_compute_subnetwork.public_subnet.self_link
}

output "network_name" {
  value = google_compute_network.vpc.name
}
