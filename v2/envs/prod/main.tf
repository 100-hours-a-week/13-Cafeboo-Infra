# GCP Provider
provider "google" {
  credentials = file("${path.module}/../../terraform-key.json")
  project     = var.project
  region      = var.region
}

# Backend
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v2-prod-tfstate"
    prefix      = "v2/prod"
    credentials = "../../terraform-key.json"
  }
}

# VPC
module "vpc" {
  source   = "../../modules/vpc"
  project  = var.project
  region   = var.region
  vpc_name = "v2-prod-vpc"

  public_subnets = {
    "a" = { cidr = "10.20.0.0/24" }
    "b" = { cidr = "10.20.1.0/24" }
  }

  private_subnets = {
    "be-a" = { cidr = "10.20.10.0/24" }
    "be-b" = { cidr = "10.20.11.0/24" }
    "ai-a" = { cidr = "10.20.20.0/24" }
    "ai-b" = { cidr = "10.20.21.0/24" }
  }
}

# nat
module "nat_a" {
  source            = "../../modules/nat"
  name              = "nat-prod-a"
  project           = var.project
  region            = var.region
  network_self_link = module.vpc.network_self_link
  subnetworks = [
    {
      name                    = module.vpc.private_subnet_self_links["be-a"]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    },
    {
      name                    = module.vpc.private_subnet_self_links["ai-a"]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  ]
}

module "nat_b" {
  source            = "../../modules/nat"
  name              = "nat-prod-b"
  project           = var.project
  region            = var.region
  network_self_link = module.vpc.network_self_link
  subnetworks = [
    {
      name                    = module.vpc.private_subnet_self_links["be-b"]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    },
    {
      name                    = module.vpc.private_subnet_self_links["ai-b"]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  ]
}

# MIG BE Group

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

## BE MIG
module "backend_mig" {
  source       = "../../modules/mig_instance_group"
  name_prefix  = "backend-mig"
  project      = var.project
  region       = var.region
  machine_type = "e2-small"
  image        = var.image
  subnetwork   = module.vpc.private_subnet_self_links["be-a"]
  tags         = ["backend"]

  startup_script = file("${path.module}/scripts/back.sh")
  metadata = {
    ssh-keys = var.ssh_public_key
  }
  target_size = 2

  health_check = google_compute_health_check.backend.self_link
  distribution_zones = [
    var.zone_A,
    var.zone_B
  ]
}

# MIG AI Group

## health check
resource "google_compute_health_check" "ai" {
  name    = "ai-health-check-prod"
  project = var.project

  http_health_check {
    port         = 8000
    request_path = "/health"
  }

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 10
}

## AI MIG
module "ai_mig" {
  source         = "../../modules/mig_instance_group"
  name_prefix    = "ai-mig"
  project        = var.project
  region         = var.region
  machine_type   = "e2-medium"
  image          = var.image
  subnetwork     = module.vpc.private_subnet_self_links["ai-a"]
  tags           = ["ai"]
  startup_script = file("${path.module}/scripts/ai.sh")

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  target_size  = 2
  health_check = google_compute_health_check.ai.self_link
  distribution_zones = [
    var.zone_A,
    var.zone_B
  ]
}

module "internal_lb" {
  source            = "../../modules/lb/internal"
  name              = "cafeboo-internal"
  project           = var.project
  region            = var.region
  network_self_link = module.vpc.network_self_link
  subnet_self_link  = module.vpc.private_subnet_self_links["ai-a"]

  instance_group_a = module.ai_mig.instance_group_self_link
}

# Https lb
module "https_lb" {
  source                 = "../../modules/lb/https"
  name                   = "cafeboo-frontend"
  project                = var.project
  gcs_bucket_name        = "frontend-cafeboo-prod"
  domain                 = "v2.cafeboo.com"
  backend_health_check   = google_compute_health_check.backend.self_link
  backend_instance_group = module.backend_mig.instance_group_self_link
}

# Cloud SQL
module "cloudsql" {
  source      = "../../modules/cloudsql"
  name_prefix = "cafeboo-sql"
  region      = var.region
  tier        = "db-custom-1-3840"
  network     = module.vpc.network_self_link
  project     = var.project
  db_password = var.db_password
}


# NCC
## Spoke 생성
resource "google_network_connectivity_spoke" "connect_vpc" {
  name     = "spoke-to-legacy-vpc"
  project  = var.project
  location = "global"

  hub = "projects/elevated-valve-459107-h8/locations/global/hubs/shared-hub"

  linked_vpc_network {
    uri = module.vpc.network_self_link
  }

  description = "Spoke to connect Terraform-managed VPC to existing legacy VPC in same project"
}

# Redis
module "redis" {
  source           = "../../modules/compute_instance"
  name             = "redis-vm"
  project          = var.project
  zone             = var.zone_A
  machine_type     = "e2-standard-2"
  image            = var.image
  subnet_self_link = module.vpc.private_subnet_self_links["be-a"]
  tags             = ["redis"]
  network_ip       = "10.20.10.2"

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  startup_script = templatefile("${path.module}/scripts/redis.sh.tpl", {
    redis_password = var.redis_password
  })
}
