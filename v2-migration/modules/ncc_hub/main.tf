resource "google_network_connectivity_hub" "v2_shared_hub" {
  name        = var.name
  project     = var.project
  description = "NCC Hub for VPC spoke connections"
}
