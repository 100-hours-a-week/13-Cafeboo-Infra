resource "google_sql_database_instance" "main" {
  name             = var.name_prefix
  database_version = "MYSQL_8_0"
  region           = var.region
  project          = var.project

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }

    availability_type = "REGIONAL" # FailOver
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
  }

  deletion_protection = false
  depends_on          = [google_service_networking_connection.private_vpc_connection]
}
