provider "google" {
  credentials = file("${path.module}/../../v2-test-key.json")
  project     = var.project
  region      = var.region
}

# Backend
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v2-prod-test"
    prefix      = "v2/shared"
    credentials = "../../v2-test-key.json"
  }
}


# VPC
module "vpc" {
  source   = "../../modules/vpc"
  project  = var.project
  region   = var.region
  vpc_name = "v2-shared-vpc"
  public_subnets = {
    zone-a = { cidr = "10.30.1.0/24" }
  }

  private_subnets = {
    zone-b = { cidr = "10.30.2.0/24" }
  }
}


# Cloud Router 생성
resource "google_compute_router" "shared_nat_router" {
  name    = "shared-nat-router"
  network = module.vpc.network_name
  region  = var.region
  project = var.project
}


# Cloud NAT 생성
resource "google_compute_router_nat" "shared_nat" {
  name                               = "shared-nat"
  router                             = google_compute_router.shared_nat_router.name
  region                             = var.region
  project                            = var.project
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

module "ncc_hub" {
  source  = "../../modules/ncc_hub"
  name    = "v2-shared-hub"
  project = var.project
}

# 모니터링 서버
module "monitoring" {
  source             = "../../modules/monitoring"
  project_id         = var.project
  host_project_id    = var.project
  service_project_id = var.project
  region             = var.region
  zone               = var.zone

  instance_name         = "monitoring-instance"
  machine_type          = "e2-small"
  disk_size             = 50
  network_tags          = ["monitoring", "prometheus", "grafana", "loki"]
  monitoring_ports      = ["9090", "3000"]
  allowed_source_ranges = ["10.0.0.0/8"]

  vpc_network_self_link = module.vpc.network_self_link
  subnet_self_link      = module.vpc.public_subnet_self_links["zone-a"]
}