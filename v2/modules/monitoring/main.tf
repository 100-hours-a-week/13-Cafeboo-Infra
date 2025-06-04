# 기존 Shared VPC 네트워크 참조
data "google_compute_network" "shared_vpc" {
  name    = var.shared_vpc_name
  project = var.host_project_id
}

# 기존 Shared VPC의 서브넷 참조
data "google_compute_subnetwork" "monitoring_subnet" {
  name    = var.subnet_name
  region  = var.region
  project = var.host_project_id
}

# terraform-key.json 파일을 로컬에서 읽어 변수로 전달
locals {
  terraform_key_json = fileexists("${path.root}/terraform-key.json") ? file("${path.root}/terraform-key.json") : ""
}

resource "google_compute_instance" "monitoring" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.service_project_id
  metadata = {
    terraform_key_json = local.terraform_key_json
  }
  metadata_startup_script = file("${path.module}/scripts/setup_monitoring.sh")

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = var.disk_size
    }
  }

  network_interface {
    network    = data.google_compute_network.shared_vpc.self_link
    subnetwork = data.google_compute_subnetwork.monitoring_subnet.self_link
  }

  service_account {
    email  = google_service_account.monitoring_service_account.email
    scopes = ["cloud-platform"]
  }

  tags = var.network_tags
}

resource "google_compute_firewall" "monitoring" {
  name    = "${var.instance_name}-allow-monitoring"
  network = data.google_compute_network.shared_vpc.self_link
  project = var.host_project_id

  allow {
    protocol = "tcp"
    ports    = var.monitoring_ports
  }

  source_ranges = var.allowed_source_ranges
  target_tags   = var.network_tags
}

resource "google_service_account" "monitoring_service_account" {
  account_id   = "${var.instance_name}-sa"
  display_name = "Monitoring Service Account"
  project      = var.service_project_id
}

# IAM roles for the monitoring service account
resource "google_project_iam_member" "monitoring_viewer" {
  project = var.service_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.monitoring_service_account.email}"
}

resource "google_project_iam_member" "monitoring_compute_viewer" {
  project = var.service_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.monitoring_service_account.email}"
}

# Shared VPC 서비스 프로젝트에 대한 IAM 권한 설정
resource "google_compute_subnetwork_iam_member" "monitoring_network_user" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = data.google_compute_subnetwork.monitoring_subnet.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.monitoring_service_account.email}"
}
