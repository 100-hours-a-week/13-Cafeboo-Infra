# SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["backend", "ai", "redis"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# ICMP (ping 등)
resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["backend", "ai"]

  allow {
    protocol = "icmp"
  }
}

# Internal 통신 허용 (10.20.0.0/16 안의 모든 인스턴스 간)
resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["10.20.0.0/16"]
  target_tags   = ["backend", "ai"]

  allow {
    protocol = "all"
  }
}

# Internal Load Balancer용 백엔드 → AI (http 포트)
resource "google_compute_firewall" "allow-ilb-ai" {
  name    = "allow-ilb-ai"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["10.20.0.0/16"] # be-a, be-b 에서 오는 트래픽
  target_tags   = ["ai"]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
}

# Health check 허용 (Google 프록시 IP 범위)
resource "google_compute_firewall" "allow-health-check" {
  name    = "allow-health-check"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["ai"]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
}

resource "google_compute_firewall" "allow-health-check-backend" {
  name    = "allow-health-check-backend"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  target_tags = ["backend"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

# prod <-> shared 
## ingress
resource "google_compute_firewall" "ingress_from_shared" {
  name    = "ingress-from-shared-vpc"
  project = var.project
  network = module.vpc.network_self_link

  direction     = "INGRESS"
  source_ranges = ["10.30.0.0/16"]

  allow {
    protocol = "all"
  }
}

## egress
resource "google_compute_firewall" "egress_to_shared" {
  name    = "egress-to-shared-vpc"
  project = var.project
  network = module.vpc.network_self_link

  direction          = "EGRESS"
  destination_ranges = ["10.30.0.0/16"]

  allow {
    protocol = "all"
  }
}

#Redis
## 내부 접근용
resource "google_compute_firewall" "allow_internal_redis" {
  name    = "allow-internal-redis"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["10.20.0.0/16"]
  target_tags   = ["redis"]

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
}

# loki 방화벽
resource "google_compute_firewall" "allow_loki_port" {
  name    = "allow-loki-3100"
  network = module.vpc.network_self_link
  project = var.project

  direction     = "INGRESS"
  source_ranges = ["10.20.0.0/16", "10.30.0.0/16"]
  target_tags   = ["loki"]

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }
}
