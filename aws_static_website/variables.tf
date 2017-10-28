variable "subdomain" {
  description = "Subdomain of the website being configured"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM SSL certificate for the subdomain"
}

variable "log_bucket" {
  description = "The bucket for storing all access logs (in a folder prefixed with resource name )"
}

variable "error_document" {
  description = "S3 bucket error page"
  default     = "error.html"
}

variable "index_document" {
  description = "S3 bucket default page"
  default     = "index.html"
}

variable "tags" {
  type    = "map"
  default = {}
}
