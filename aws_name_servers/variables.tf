variable "domain" {
  description = "Domain for which Route53 Zone File is to be created"
}

variable "ttl" {
  description = "Time-To-Live of DNS Records in seconds"
  default     = false
}

variable "whitelabel" {
  description = "If white-labelled NS records are to created"
  default     = "false"
}
