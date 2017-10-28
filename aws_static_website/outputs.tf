output "bucket_name" {
  description = "Name of the S3 bucket from which content for the website is pulled"
  value       = "${aws_s3_bucket.website_bucket.id}"
}
