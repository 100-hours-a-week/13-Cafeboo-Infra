# GCP Provider
provider "google" {
  credentials = file("../../../terraform-key.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

# Backend
terraform {
  backend "gcs" {
    bucket      = "cafeboo-v1-prod-tfstate"
    prefix      = "v1/prod"
    credentials = "../../../terraform-key.json"
  }
}

# Static IP
resource "google_compute_address" "cpu_static_ip" {
  name    = "cafeboo-cpu-ip"
  region  = var.region
  project = var.project
}

resource "google_compute_address" "gpu_static_ip" {
  name    = "cafeboo-gpu-ip"
  region  = var.region
  project = var.project
}

# VPC 네트워크
module "vpc" {
  source             = "../../modules/vpc"
  project            = var.project
  region             = var.region
  vpc_name           = "cafeboo-vpc-v1"
  public_subnet_cidr = "10.10.0.0/24"
}

# 방화벽 규칙
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cpu"]
}

# CPU VM
module "vm_cpu" {
  source           = "../../modules/compute"
  project          = var.project
  zone             = var.zone
  name             = "cafeboo-cpu"
  machine_type     = "e2-medium"
  image            = var.image
  external_ip      = google_compute_address.cpu_static_ip.address
  subnet_self_link = module.vpc.subnet_self_link

  tags   = ["cpu"]
  labels = { role = "cpu" }

  metadata = {
    startup-script = file("${path.module}/scripts/init-cpu.sh")
    ssh-keys       = "cafeboo:${file("../../../gcp-vm-key.pub")}"
  }
}

## GPU VM
# module "vm_gpu" {
#   source           = "../../modules/compute"
#   project          = var.project
#   zone             = var.zone
#   name             = "cafeboo-gpu"
#   machine_type     = "n1-standard-4"
#   image            = var.image
#   external_ip = google_compute_address.gpu_static_ip.address
#   subnet_self_link = module.vpc.subnet_self_link
#   tags             = ["gpu"]
#   labels           = { role = "gpu" }
#   gpu_enabled      = true
#   gpu_type         = "nvidia-tesla-t4"
#   gpu_count        = 1

#   metadata = {
#     startup-script = file("${path.module}/scripts/init-gpu.sh")
#   }
# }
