variable "project" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "asia-northeast3"
}

variable "bucket_name" {
  type        = string
  description = "Name of the GCS bucket"
}

variable "embedding_model_path" {
  type        = string
  description = "Local path to the embedding_model.tar.gz"
}

variable "best_model_path" {
  type        = string
  description = "Local path to the best_model.pt"
}

variable "make_public" {
  type        = bool
  default     = false
  description = "Whether to make bucket objects publicly accessible"
}
