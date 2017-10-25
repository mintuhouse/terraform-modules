provider "mailgun" {
  api_key = "${var.api_key}"
}

locals {
  sdomain    = "${var.subdomain}.${var.domain}"
  fulldomain = "${var.subdomain == "" ? var.domain : local.sdomain}"
}

resource "mailgun_domain" "primary" {
  name          = "${local.fulldomain}"
  smtp_password = "${var.smtp_password}"
  spam_action   = "${var.spam_action}"
  wildcard      = "${var.wildcard}"

  # As mailgun may disable the domain sometimes
  lifecycle {
    prevent_destroy = true
  }
}

data "aws_route53_zone" "primary" {
  name = "${var.domain}"
}

# Also used for domain verification by mailgun
resource "aws_route53_record" "primary_mailgun_sending_records" {
  count   = 3
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${lookup(mailgun_domain.primary.sending_records[count.index], "name")}"
  type    = "${lookup(mailgun_domain.primary.sending_records[count.index], "record_type")}"
  ttl     = "300"
  records = ["${lookup(mailgun_domain.primary.sending_records[count.index], "value")}"]
}

resource "aws_route53_record" "primary_mailgun_mx" {
  count   = "${var.mode != "send-only" ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.fulldomain}"
  type    = "MX"
  ttl     = "300"
  records = ["10 mxa.mailgun.org", "10 mxb.mailgun.org"]
}
