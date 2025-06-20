output "embedding_model_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.model_bucket.name}/${google_storage_bucket_object.embedding_model.name}"
}

output "best_model_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.model_bucket.name}/${google_storage_bucket_object.best_model.name}"
}
