locals {
  terraform_key_json = file("${path.module}/../../v2-test-key.json")
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
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size
    }
  }
  

  network_interface {
    network    = var.vpc_network_self_link
    subnetwork = var.subnet_self_link
    network_ip = google_compute_address.monitoring_ip.address
  }

  service_account {
    email  = google_service_account.monitoring_service_account.email
    scopes = ["cloud-platform"]
  }

  tags = var.network_tags
}

resource "google_compute_firewall" "monitoring" {
  name    = "${var.instance_name}-allow-monitoring"
  network = var.vpc_network_self_link
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
  subnetwork = var.subnet_self_link
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.monitoring_service_account.email}"
}

resource "google_compute_address" "monitoring_ip" {
  name         = "monitoring-fixed-ip"
  address_type = "INTERNAL"
  address      = "10.30.1.19"
  region       = var.region
  subnetwork   = var.subnet_self_link
  project      = var.project_id
}
