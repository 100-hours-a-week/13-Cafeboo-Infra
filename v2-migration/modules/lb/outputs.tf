output "lb_ip" {
  value = google_compute_global_address.lb_ip.address
}
output "backend_service_self_link" {
  description = "Backend Service의 self_link"
  value       = google_compute_backend_service.backend.self_link
}

output "frontend_bucket_self_link" {
  description = "프론트엔드 Backend-Bucket 의 self_link"
  value       = google_compute_backend_bucket.frontend.self_link
}
