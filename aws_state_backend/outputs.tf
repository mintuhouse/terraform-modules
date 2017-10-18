output "bucket_name" {
  value = "${aws_s3_bucket.remote-state.id}"
}

output "dynamodb_table_name" {
  value = "${aws_dynamodb_table.terraform-state-lock.id}"
}