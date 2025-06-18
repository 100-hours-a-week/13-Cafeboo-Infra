# HTTP 허용 (외부에서 80 포트 접근)
resource "google_compute_firewall" "allow_http" {
  name    = "dev-vpc-allow-http"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
  target_tags   = ["http-server"]
}

# SSH 허용
resource "google_compute_firewall" "allow_ssh" {
  name    = "dev-vpc-allow-ssh"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = 65534
}

# IAP로 SSH 접속
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"] # IAP 고정 IP 범위
  priority      = 1000
  target_tags = ["iap-access"]

}

# Health check용 허용
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check-dev-backend"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # GCP LB health check IP
  priority      = 1000
  target_tags   = ["http-server"]
}


# shared VPC 허용
resource "google_compute_firewall" "allow_from_shared" {
  name    = "allow-from-shared"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "3306"]
  }

  source_ranges = ["10.30.0.0/16"]

  direction = "INGRESS"
  priority  = 1000
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mysql-enabled"]
}

resource "google_compute_firewall" "allow_vpn_to_ai_8000" {
  name    = "allow-vpn-to-ai-8000"
  network = module.vpc.network_self_link

  description = "vpn을 통한 ai 서버 접속 허용"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["10.30.1.3/32"]
  target_tags = ["allow-vpn-to-ai"]

}
