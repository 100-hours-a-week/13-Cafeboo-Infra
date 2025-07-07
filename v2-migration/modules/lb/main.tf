resource "google_compute_health_check" "http" {
  name               = "${var.name}-http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 8080
    request_path = "/actuator/health"
  }
}

#인스턴스 그룹 생성
resource "google_compute_instance_group" "group" {
  name     = "${var.name}-instance-group"
  zone     = var.zone
  instances = [var.vm_self_link]

  named_port {
    name = "http"
    port = 8080
  }
}

# 백엔드 서비스 생성
resource "google_compute_backend_service" "backend" {
  name                            = "${var.name}-backend-service"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 30
  health_checks                   = [google_compute_health_check.http.self_link]
  backend {
    group = google_compute_instance_group.group.self_link
  }
}

# URL 맵, HTTP 프록시, 글로벌 주소 및 포워딩 규칙 생성
resource "google_compute_url_map" "url_map" {
  name = "${var.name}-url-map"

  // default는 프론트엔드 버킷
  default_service = google_compute_backend_bucket.frontend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher"
  }

  path_matcher {
    name            = "path-matcher"
    default_service = google_compute_backend_bucket.frontend.self_link

    // /api/*, /ws/* 는 백엔드 서비스로
    path_rule {
      paths   = ["/api/*", "/ws/*"]
      service = google_compute_backend_service.backend.self_link
    }
  }
}

# SSL 인증서 생성
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${var.name}-ssl-cert"

  managed {
    domains = ["doraa.net"]
  }
}

# 글로벌 IP 주소 예약
resource "google_compute_global_address" "lb_ip" {
  name    = var.lb_ip_name
  project = var.project
}

# HTTPS 프록시
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.name}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

resource "google_compute_global_forwarding_rule" "https_rule" {
  name       = "${var.name}-https-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "443"
  target     = google_compute_target_https_proxy.https_proxy.self_link
}

# 프론트엔드 버킷 생성
resource "google_storage_bucket" "frontend" {
  name          = var.frontend_bucket_name
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

# 퍼블릭 읽기 권한 부여 (AllUsers → objectViewer)
resource "google_storage_bucket_iam_binding" "frontend_public_read" {
  bucket = google_storage_bucket.frontend.name

  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# 프론트엔드 Backend Bucket
resource "google_compute_backend_bucket" "frontend" {
  name        = "${var.name}-frontend-bucket"
  bucket_name = google_storage_bucket.frontend.name
  enable_cdn  = true
}