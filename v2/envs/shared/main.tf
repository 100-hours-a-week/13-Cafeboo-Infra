provider "google" {
  credentials = file("${path.module}/../../terraform-key.json")
  project     = var.project_id
  region      = var.region
}

# Backend
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v2-prod-tfstate"
    prefix      = "v2/shared"
    credentials = "../../terraform-key.json"
  }
}

data "google_compute_network" "shared_vpc" {
  name    = "shared-vpc"
  project = var.project_id
}

# Cloud Router 생성
resource "google_compute_router" "shared_nat_router" {
  name    = "shared-nat-router"
  network = data.google_compute_network.shared_vpc.self_link
  region  = var.region
  project = var.project_id
}

# Cloud NAT 생성
resource "google_compute_router_nat" "shared_nat" {
  name                               = "shared-nat"
  router                             = google_compute_router.shared_nat_router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 모니터링 서버
module "monitoring" {
  source             = "../../modules/monitoring"
  project_id         = var.project_id
  host_project_id    = var.project_id
  service_project_id = var.project_id
  shared_vpc_name    = "shared-vpc"
  subnet_name        = "shared-private-subnet"
  region             = var.region
  zone               = var.zone

  instance_name         = "monitoring-instance"
  machine_type          = "e2-small"
  disk_size             = 50
  network_tags          = ["monitoring", "prometheus", "grafana", "loki"]
  monitoring_ports      = ["9090", "3000"]
  allowed_source_ranges = ["10.0.0.0/8"]
}
