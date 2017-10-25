variable "api_key" {}

variable "domain" {
  description = "email domain for catch-all forwarding"
}

variable "smtp_password" {
  description = "SMTP Password"
}

variable "subdomain" {
  description = "Subdomain for Mailgun MX records"
}

variable "spam_action" {
  default     = "tag"
  description = "Spam filter behavior, (tag or disabled)."
}

variable "wildcard" {
  default     = true
  description = "Determines whether the domain will accept email for sub-domains."
}

variable "mode" {
  default     = "send-only"
  description = "Valid Options: send-only, send-receive"
}
