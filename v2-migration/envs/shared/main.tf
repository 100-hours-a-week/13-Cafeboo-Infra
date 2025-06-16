provider "google" {
  credentials = file("${path.module}/../../terraform-key-cafeboo33.json")
  project     = var.project
  region      = var.region
}

# 상태 관리
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v2-dev-tfstate"
    prefix      = "v2/shared"
    credentials = "../../terraform-key-cafeboo33.json"
  }
}

# VPC
module "vpc" {
  source   = "../../modules/vpc"
  project  = var.project
  region   = var.region
  vpc_name = "v2-shared-vpc"
  public_subnet_cidr  = "10.30.1.0/24"
  private_subnet_cidr = "10.30.2.0/24"
}

# Cloud Router 생성
resource "google_compute_router" "v2_shared_nat_router" {
  name    = "v2-shared-nat-router"
  network = module.vpc.network_name
  region  = var.region
  project = var.project
}

# Cloud NAT 생성
resource "google_compute_router_nat" "v2_shared_nat" {
  name                               = "v2-shared-nat"
  router                             = google_compute_router.v2_shared_nat_router.name
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

## openvpn 설정

# OpenVPN 외부 IP
data "google_compute_address" "openvpn_ip" {
  name   = "openvpn-static-ip" 
  region = var.region
}

module "openvpn" {
  source     = "../../modules/openvpn"
  project    = var.project
  region     = var.region
  zone       = var.zone
  subnet     = module.vpc.public_subnet_self_link
  static_ip  = data.google_compute_address.openvpn_ip.address
  instance_name = "openvpn-vm"
  startup_script_path = "${path.module}/scripts/openvpn_setup.sh"
  tags       = ["openvpn-server"]
}

/*
# 모니터링 서버
module "monitoring" {
  source             = "../../modules/monitoring"
  project_id         = var.project
  host_project_id    = var.project
  service_project_id = var.project
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
*/

