# ───────────────────────────────────────────────────────────────
# Loki 포트 (3100) 허용 – 내부 통신용
# ───────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_loki_port" {
  name    = "allow-loki-3100"
  network = module.vpc.network_name
  project = var.project

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["10.10.0.0/16", "10.20.0.0/16", "10.30.0.0/16"]
  target_tags   = ["loki"]

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }
}

# ───────────────────────────────────────────────────────────────
# OpenVPN 포트 (UDP 1194) 허용 – 클라이언트용
# ───────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_openvpn_udp" {
  name    = "allow-openvpn"
  network = module.vpc.network_name
  project = var.project

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
}

# ───────────────────────────────────────────────────────────────
# 내부망(dev) → 서비스 인스턴스 접근 허용 (ICMP, SSH, Web, DB 등)
# ───────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_from_dev" {
  name    = "allow-from-dev"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["10.10.0.0/16"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "3306"]
  }
}

# ───────────────────────────────────────────────────────────────
# 외부에서 OpenVPN 연결용 포트 허용 (tcp:3100, 6100 등)
# ───────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_to_openvpn_connect" {
  name    = "allow-to-openvpn-connect"
  network = module.vpc.network_name
  project = var.project

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]
  disabled      = false

  allow {
    protocol = "tcp"
    ports    = ["3100", "6100", "6180", "6188"]
  }
}

# ───────────────────────────────────────────────────────────────
# OpenVPN 웹 UI (Admin 및 Client용 - 포트 943)
# ───────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_openvpn_admin" {
  name    = "allow-openvpn-admin"
  network = module.vpc.network_name
  project = var.project

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn-server"]
  disabled      = false

  allow {
    protocol = "tcp"
    ports    = ["943"]
  }
}
