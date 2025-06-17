resource "google_compute_instance" "openvpn_instance" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = var.zone
  project      = var.project

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = var.subnet
    access_config {
      nat_ip = var.static_ip
    }
  }
  tags                    = var.tags
}
