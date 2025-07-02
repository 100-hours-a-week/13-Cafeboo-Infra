resource "google_compute_health_check" "internal" {
  name                = "${var.name}-hc"
  project             = var.project
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = 8000
  }
}

resource "google_compute_region_backend_service" "internal" {
  name                  = "${var.name}-backend-service"
  project               = var.project
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.internal.id]

  backend {
    group          = var.instance_group_a
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_forwarding_rule" "internal" {
  name                  = "${var.name}-forwarding-rule"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.internal.id
  ip_protocol           = "TCP"
  ports                 = ["8000"]
  subnetwork            = var.subnet_self_link
  network               = var.network_self_link
  ip_address            = var.ip_address
}
