output "smtp_login" {
  value = "${mailgun_domain.primary.smtp_login}"
}

output "smtp_password" {
  value = "${mailgun_domain.primary.smtp_password}"
}

output "configuration" {
  value = "Please visit https://app.mailgun.com/app/domains/${var.subdomain}.${var.domain} and click 'Check DNS Records Now'"
}
