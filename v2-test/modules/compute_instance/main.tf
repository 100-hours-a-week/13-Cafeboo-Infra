resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  metadata = var.metadata

  metadata_startup_script = var.startup_script
  tags                    = var.tags
}
