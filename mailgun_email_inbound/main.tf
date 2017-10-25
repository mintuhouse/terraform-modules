module "email_setup_mailgun" {
  source        = "../mailgun_email_setup"
  api_key       = "${var.api_key}"
  domain        = "${var.domain}"
  smtp_password = "${var.smtp_password}"
  subdomain     = "${var.subdomain}"
  spam_action   = "${var.spam_action}"
  wildcard      = "${var.wildcard}"
  mode          = "${var.mode}"
}

resource "mailgun_route" "catchall" {
  priority    = "100"
  description = "catch all emails to ${var.domain}"
  expression  = "match_recipient('.*@${var.domain}')"

  actions = [
    "forward('${var.catchall_email}')",
    "stop()",
  ]
}
