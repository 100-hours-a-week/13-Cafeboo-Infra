# modules/vpc/main.tf

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project
  description             = "Custom VPC with public and private subnets"
}

resource "google_compute_subnetwork" "public_subnets" {
  for_each = var.public_subnets

  name                     = "${var.vpc_name}-public-${each.key}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  description              = "Public subnet in zone ${each.key}"
  private_ip_google_access = false
}

resource "google_compute_subnetwork" "private_subnets" {
  for_each = var.private_subnets

  name                     = "${var.vpc_name}-private-${each.key}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  description              = "Private subnet for ${each.key}"
  private_ip_google_access = true
}
