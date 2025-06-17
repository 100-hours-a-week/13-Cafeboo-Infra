#Terraform이 만든 리소스들의 정보를 외부에서 쉽게 볼 수 있도록 출력

output "network_name" {
  description = "VPC 네트워크 이름"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "VPC self_link"
  value       = google_compute_network.vpc.self_link
}

output "public_subnet_self_link" {
  description = "퍼블릭 서브넷 self_link"
  value       = google_compute_subnetwork.public_subnet.self_link
}

output "private_subnet_self_link" {
  description = "프라이빗 서브넷 self_link"
  value       = google_compute_subnetwork.private_subnet.self_link
}

output "public_subnet_name" {
  description = "퍼블릭 서브넷 이름"
  value       = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_name" {
  description = "프라이빗 서브넷 이름"
  value       = google_compute_subnetwork.private_subnet.name
}

