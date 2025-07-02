output "instance_group_manager" {
  value = google_compute_region_instance_group_manager.this.self_link
}

output "instance_template" {
  value = google_compute_instance_template.this.self_link
}

output "instance_group_self_link" {
  value = google_compute_region_instance_group_manager.this.instance_group
}

output "instance_group_name" {
  value = google_compute_region_instance_group_manager.this.instance_group
}
