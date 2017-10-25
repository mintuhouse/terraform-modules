variable "api_key" {
  default = "" # Unused
}

variable "domain" {
  description = "email domain for catch-all forwarding"
}

variable "catchall_email" {
  description = "EmailID to which all unmatched emails are to be forwarded"
}
