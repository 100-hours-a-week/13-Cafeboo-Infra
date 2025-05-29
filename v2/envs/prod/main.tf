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

