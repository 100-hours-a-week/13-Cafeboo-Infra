resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project

  boot_disk {
    initialize_params {
      image = var.image
      size  = 100
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    access_config {
    nat_ip = var.external_ip
  }
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  metadata = var.metadata

  metadata_startup_script = var.startup_script
  tags                    = var.tags
}
