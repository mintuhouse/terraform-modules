provider "mailgun" {
  api_key = "${var.api_key}"
}

resource "mailgun_domain" "primary" {
  name          = "${var.subdomain}.${var.domain}"
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

resource "aws_route53_record" "primary_mailgun_sending_records" {
  count   = 3
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${lookup(mailgun_domain.primary.sending_records[count.index], "name")}"
  type    = "${lookup(mailgun_domain.primary.sending_records[count.index], "record_type")}"
  ttl     = "300"
  records = ["${lookup(mailgun_domain.primary.sending_records[count.index], "value")}"]
}

# Recommended even if you are only sending email
resource "aws_route53_record" "primary_improvmx_mx" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${var.subdomain}.${var.domain}"
  type    = "MX"
  ttl     = "300"
  records = ["10 mxa.mailgun.org", "10 mxb.mailgun.org"]
}
