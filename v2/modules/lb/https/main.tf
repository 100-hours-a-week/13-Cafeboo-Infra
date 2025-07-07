resource "google_compute_global_address" "https_lb_ip" {
  name    = "httpslb-ip"
  project = var.project
}

resource "google_compute_managed_ssl_certificate" "cafeboo_ssl" {
  name    = "${var.name}-ssl-cert"
  project = var.project

  managed {
    domains = [var.domain]
  }
}

resource "google_storage_bucket" "frontend_bucket" {
  name                        = "v2-prod-frontend-bucket"
  location                    = var.region
  project                     = var.project
  force_destroy               = true
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.frontend_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "frontend" {
  name        = "frontend-bucket-backend"
  bucket_name = var.gcs_bucket_name
  enable_cdn  = true
  project     = var.project
}

resource "google_compute_url_map" "https" {
  name            = var.name
  project         = var.project
  default_service = google_compute_backend_bucket.frontend.self_link

  path_matcher {
    name            = "api-backend"
    default_service = google_compute_backend_bucket.frontend.self_link

    path_rule {
      paths   = ["/api/*", "/ws/*"]
      service = google_compute_backend_service.backend.self_link
    }
  }

  host_rule {
    hosts        = ["*"]
    path_matcher = "api-backend"
  }
}

resource "google_compute_target_https_proxy" "https" {
  name             = var.name
  url_map          = google_compute_url_map.https.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.cafeboo_ssl.self_link]
  project          = var.project
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = var.name
  target                = google_compute_target_https_proxy.https.self_link
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.https_lb_ip.address
  project               = var.project
}

resource "google_compute_backend_service" "backend" {
  name        = "prod-backend-service"
  project     = var.project
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 600

  health_checks = [var.backend_health_check]

  backend {
    group = var.backend_instance_group
  }
}
