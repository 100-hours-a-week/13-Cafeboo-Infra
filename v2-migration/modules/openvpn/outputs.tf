output "internal_ip" {
  description = "The internal IP of the OpenVPN VM"
  value       = google_compute_instance.openvpn_instance.network_interface[0].network_ip
}

output "external_ip" {
  description = "The external (static) IP of the OpenVPN VM"
  value       = google_compute_instance.openvpn_instance.network_interface[0].access_config[0].nat_ip
}

output "openvpn_self_link" {
  description = "The self link of the OpenVPN VM"
  value       = google_compute_instance.openvpn_instance.self_link
}
