resource "google_compute_instance_template" "this" {
  name_prefix  = var.name_prefix
  project      = var.project
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
    disk_size_gb = 100
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  tags     = var.tags
  metadata = var.metadata

  metadata_startup_script = var.startup_script

  labels = {
    managed-by-mig = "true"
  }
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = var.name_prefix
  project            = var.project
  region             = var.region
  base_instance_name = var.name_prefix

  version {
    instance_template = google_compute_instance_template.this.self_link
  }

  target_size = var.target_size

  distribution_policy_zones = var.distribution_zones

  auto_healing_policies {
    health_check      = var.health_check
    initial_delay_sec = 300
  }
}
