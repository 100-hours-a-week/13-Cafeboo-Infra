# GCP Provider
provider "google" {
  credentials = file("${path.module}/../terraform-key-cafeboo33.json")
  project     = var.project
  region      = var.region
}

# GCS 버킷 생성
resource "google_storage_bucket" "tfstate" {
  name          = var.bucket_name
  location      = var.region
  project       = var.project
  force_destroy = true

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}
