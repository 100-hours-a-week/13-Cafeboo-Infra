# GCP Provider
provider "google" {
  credentials = file("${path.module}/../../terraform-key-cafeboo33.json")
  project     = var.project
  region      = var.region
}

# 상태 관리
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v2-dev-tfstate"
    prefix      = "v2/dev"
    credentials = "../../terraform-key-cafeboo33.json"
  }
}

# VPC
module "vpc" {
  source   = "../../modules/vpc"
  project  = var.project
  region   = var.region
  vpc_name = "v2-dev-vpc"
  public_subnet_cidr  = "10.10.1.0/24"
  private_subnet_cidr = "10.10.2.0/24"
}

# nat
module "nat" {
  source            = "../../modules/nat"
  name              = "v2-dev"
  project           = var.project
  region            = var.region
  network_self_link = module.vpc.network_self_link
  subnetworks = [
    {
      name                    = module.vpc.private_subnet_self_link
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  ]

}

# vm 
module "dev_vm" {
  source              = "../../modules/compute_instance"
  name                = "dev-vm"
  machine_type        = "e2-medium"
  region              = var.region
  zone                = var.zone
  project             = var.project
  image               = "ubuntu-os-cloud/ubuntu-2204-lts"
  subnet_self_link    = module.vpc.public_subnet_self_link
  metadata            = {}
  startup_script      = file("${path.module}/scripts/setup.sh")
  tags                = ["dev"]
}

# HTTPS Load Balancer
module "lb" {
  source         = "../../modules/lb"
  name           = "v2-dev"
  region         = var.region
  project        = var.project
  zone           = var.zone
  vm_self_link   = module.dev_vm.instance_self_link

  frontend_bucket_name = "v2-dev-frontend-bucket"
}


## health check
resource "google_compute_health_check" "backend" {
  name    = "backend-health-check-prod"
  project = var.project

  http_health_check {
    port         = 8080
    request_path = "/actuator/health"
  }

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 10
}

resource "google_network_connectivity_spoke" "dev_spoke" {
  name     = "spoke-to-shared-hub"
  project  = var.project
  location = "global"

  hub = var.hub_id

  linked_vpc_network {
    uri = module.vpc.network_self_link
  }

  description = "Spoke to connect dev VPC to shared NCC Hub"
}


