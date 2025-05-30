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

# Compute Instance

## Back
module "backend_a" {
  source           = "../../modules/compute_instance"
  name             = "backend-a"
  project          = var.project
  zone             = var.zone_A
  machine_type     = "e2-small"
  image            = var.image
  subnet_self_link = module.vpc.private_subnet_self_links["be-a"]
  startup_script   = file("${path.module}/scripts/back.sh")
  tags             = ["backend"]
  metadata = {
    ssh-keys = var.ssh_public_key
  }
}

module "backend_b" {
  source           = "../../modules/compute_instance"
  name             = "backend-b"
  project          = var.project
  zone             = var.zone_B
  machine_type     = "e2-small"
  image            = var.image
  subnet_self_link = module.vpc.private_subnet_self_links["be-b"]
  startup_script   = file("${path.module}/scripts/back.sh")
  tags             = ["backend"]
  metadata = {
    ssh-keys = var.ssh_public_key
  }
}
}

## AI

module "ai_a" {
  source           = "../../modules/compute_instance"
  name             = "ai-a"
  project          = var.project
  zone             = var.zone_A
  machine_type     = "e2-small"
  image            = var.image
  subnet_self_link = module.vpc.private_subnet_self_links["ai-a"]
  startup_script   = file("${path.module}/scripts/ai.sh")
  tags             = ["ai"]
  metadata = {
    ssh-keys = var.ssh_public_key
  }
}

module "ai_b" {
  source           = "../../modules/compute_instance"
  name             = "ai-b"
  project          = var.project
  zone             = var.zone_B
  machine_type     = "e2-small"
  image            = var.image
  subnet_self_link = module.vpc.private_subnet_self_links["ai-b"]
  startup_script   = file("${path.module}/scripts/ai.sh")
  tags             = ["ai"]
  metadata = {
    ssh-keys = var.ssh_public_key
  }
}

# AI Instance Group
resource "google_compute_instance_group" "ai_group_a" {
  name      = "cafeboo-ai-group-a"
  zone      = var.zone_A
  project   = var.project
  instances = [module.ai_a.instance_self_link]

  named_port {
    name = "http"
    port = 8000
  }
}

resource "google_compute_instance_group" "ai_group_b" {
  name      = "cafeboo-ai-group-b"
  zone      = var.zone_B
  project   = var.project
  instances = [module.ai_b.instance_self_link]

  named_port {
    name = "http"
    port = 8000
  }
}

module "internal_lb" {
  source            = "../../modules/lb/internal"
  name              = "cafeboo-internal"
  project           = var.project
  region            = var.region
  network_self_link = module.vpc.network_self_link
  subnet_self_link  = module.vpc.private_subnet_self_links["ai-a"]

  instance_group_a = google_compute_instance_group.ai_group_a.self_link
  instance_group_b = google_compute_instance_group.ai_group_b.self_link
}

# Cloud SQL

module "cloudsql" {
  source      = "../../modules/cloudsql"
  name_prefix = "cafeboo-sql"
  region      = var.region
  tier        = "db-custom-1-3840"
  network     = module.vpc.network_self_link
  project     = var.project
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
