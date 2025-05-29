output "network_name" {
  value = google_compute_network.vpc.name
}

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "public_subnet_self_links" {
  value = {
    for k, s in google_compute_subnetwork.public_subnets : k => s.self_link
  }
}

output "private_subnet_self_links" {
  value = {
    for k, s in google_compute_subnetwork.private_subnets : k => s.self_link
  }
}
