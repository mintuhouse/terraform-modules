variable "domain" {
  description = "Domain for which Route53 Zone File is to be created"
}

variable "whitelabel" {
  description = "If white-labelled NS records are to created"
  default     = "false"
}

variable "whitelabel_domain" {
  description = "Domain of white-labelled NS records (Same as `var.domain` if empty)"
  default     = ""
}

variable "ttl" {
  description = "Time-To-Live of DNS Records in seconds"
  default     = false
}

variable "route53_delegation_set_id" {
  description = "Route53 NS servers delegation set id"
}
