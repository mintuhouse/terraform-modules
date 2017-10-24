variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain from which emails are sent"
}

variable "mail_from" {
  description = "MAIL FROM / Return Path subdomain"
  default     = "bounce"
}
