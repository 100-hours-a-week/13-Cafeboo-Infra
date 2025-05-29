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

