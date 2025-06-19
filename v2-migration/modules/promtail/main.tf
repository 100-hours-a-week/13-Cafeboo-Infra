resource "google_compute_instance" "promtail" {
  name         = "promtail-dev"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["promtail"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {}
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tpl", {
    loki_url   = var.loki_url,
    instance   = var.instance_label,
    job_label  = var.job_label
  })

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}
