output "shared_hub_self_link" {
  description = "Self link of the NCC Hub"
  value       = google_network_connectivity_hub.v2_shared_hub.id
}
