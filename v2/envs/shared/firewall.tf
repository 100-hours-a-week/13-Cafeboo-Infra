# loki 방화벽
resource "google_compute_firewall" "allow_loki_port" {
  name    = "allow-loki-3100"
  network = data.google_compute_network.shared_vpc.self_link
  project = var.project_id

  direction     = "INGRESS"
  source_ranges = ["10.10.0.0/16", "10.20.0.0/16", "10.30.0.0/16"]
  target_tags   = ["loki"]

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }
}
