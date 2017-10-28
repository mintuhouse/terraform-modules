variable "subdomains" {
  type        = "list"
  description = "List of FQDNs which should redirect to target"
}

variable "target" {
  description = "Target subdomain to which current subdomain has to be redirected (https by default)"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM SSL certificate for the subdomain"
}

variable "log_bucket" {
  description = "The bucket for storing all access logs (in a folder prefixed with resource name )"
}

variable "tags" {
  type    = "map"
  default = {}
}
