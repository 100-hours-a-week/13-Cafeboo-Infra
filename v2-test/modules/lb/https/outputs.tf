output "https_lb_ip_address" {
  description = "External IP address of the HTTPS load balancer"
  value       = google_compute_global_address.https_lb_ip.address
}

output "ssl_certificate_self_link" {
  description = "Self link of the managed SSL certificate"
  value       = google_compute_managed_ssl_certificate.cafeboo_ssl.self_link
}

output "url_map_self_link" {
  description = "Self link of the URL map"
  value       = google_compute_url_map.https.self_link
}

output "target_https_proxy_self_link" {
  description = "Self link of the HTTPS proxy"
  value       = google_compute_target_https_proxy.https.self_link
}

output "global_forwarding_rule_name" {
  description = "Name of the global forwarding rule"
  value       = google_compute_global_forwarding_rule.https.name
}

output "backend_service_self_link" {
  description = "Self link of the backend service (MIG)"
  value       = google_compute_backend_service.backend.self_link
}
