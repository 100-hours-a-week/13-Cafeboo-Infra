resource "google_artifact_registry_repository" "this" {
  location = var.region
  format   = var.format
  repository_id = var.name
}
