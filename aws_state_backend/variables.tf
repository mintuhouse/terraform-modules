variable "s3_terraform_log_bucket_name" {
  description = "Bucket name for storing terraform logs"
}

variable "s3_remote_state_bucket_name" {
  description = "Bucket name for storing remote state"
}

variable "dynamodb_lock_table_name" {
  description = "DynamoDB table name for storing lock"
}
