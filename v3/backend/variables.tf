variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-northeast-2"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform backend state"
  type        = string
  default     = "cafeboo-terraform-v3-backend-bucket"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-v3-lock-table"
}
