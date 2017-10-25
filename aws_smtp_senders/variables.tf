variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "domain" {
  description = "Email Domain"
}

variable "smtp_email_ids" {
  description = "Comma separated list of SMTP email IDs (leave out the `@domain.tld` part)"
}
