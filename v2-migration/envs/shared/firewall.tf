# loki 방화벽
resource "google_compute_firewall" "allow_loki_port" {
  name    = "allow-loki-3100"
  network = module.vpc.network_name

  project = var.project

  direction     = "INGRESS"
  source_ranges = ["10.10.0.0/16", "10.20.0.0/16", "10.30.0.0/16"]
  target_tags   = ["loki"]

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }
}

# OpenVPN 방화벽 (UDP 1194)
resource "google_compute_firewall" "allow_openvpn_udp" {
  name    = "allow-openvpn"
  network = module.vpc.network_name
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
}

resource "google_compute_firewall" "allow_from_dev" {
  name    = "allow-from-dev"
  network = module.vpc.network_self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "3306"] # 필요에 따라 추가
  }

  source_ranges = ["10.10.0.0/16"]

  direction = "INGRESS"
  priority  = 1000
}
