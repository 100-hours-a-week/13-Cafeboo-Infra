resource "google_storage_bucket" "model_bucket" {
  name     = var.bucket_name
  location = var.region
  project  = var.project

  force_destroy = true # 버킷 삭제 시 객체도 함께 삭제
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "embedding_model" {
  name   = "embedding_model.tar.gz"
  bucket = google_storage_bucket.model_bucket.name
  source = var.embedding_model_path
  content_type = "application/gzip"
}

resource "google_storage_bucket_object" "best_model" {
  name   = "moderation_model/best_model.pt"
  bucket = google_storage_bucket.model_bucket.name
  source = var.best_model_path
  content_type = "application/octet-stream"
}

# 선택: 퍼블릭 액세스 허용
resource "google_storage_bucket_iam_binding" "public_access" {
  count   = var.make_public ? 1 : 0
  bucket  = google_storage_bucket.model_bucket.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}
