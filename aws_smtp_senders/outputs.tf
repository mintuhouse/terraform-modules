output "smtp_credentials" {
  value       = ["${data.null_data_source.smtp_credentials.*.outputs}"]
  description = "List of SMTP credentials"
}
