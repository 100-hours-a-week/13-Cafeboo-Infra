resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project
  description             = "Custom VPC with one public and one private subnet"
}

resource "google_compute_subnetwork" "public_subnet" {
  name                     = "${var.vpc_name}-public"
  ip_cidr_range            = var.public_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = false
  description              = "Public subnet for internet-facing resources"
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.vpc_name}-private"
  ip_cidr_range            = var.private_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  description              = "Private subnet for internal VMs"
}
