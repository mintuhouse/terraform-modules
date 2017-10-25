provider "aws" {
  alias  = "${var.region}"
  region = "${var.region}"
}

resource "aws_ses_domain_identity" "primary" {
  provider = "aws.${var.region}"
  domain   = "${var.domain}"
}

locals {
  domain           = "${aws_ses_domain_identity.primary.domain}"
  zone_id          = "${data.aws_route53_zone.primary.zone_id}"
  mail_from_domain = "${var.mail_from}.${local.domain}"
}

data "aws_route53_zone" "primary" {
  provider = "aws.${var.region}"
  name     = "${local.domain}"
}

resource "aws_route53_record" "primary_amazonses_verification_record" {
  provider = "aws.${var.region}"
  zone_id  = "${local.zone_id}"
  name     = "_amazonses.${local.domain}"
  type     = "TXT"
  ttl      = "600"
  records  = ["${aws_ses_domain_identity.primary.verification_token}"]
}

resource "aws_ses_domain_dkim" "primary" {
  provider = "aws.${var.region}"
  domain   = "${local.domain}"
}

resource "aws_route53_record" "primary_amazonses_dkim_record" {
  provider = "aws.${var.region}"
  count    = 3
  zone_id  = "${local.zone_id}"
  name     = "${element(aws_ses_domain_dkim.primary.dkim_tokens, count.index)}._domainkey.${local.domain}"
  type     = "CNAME"
  ttl      = "600"
  records  = ["${element(aws_ses_domain_dkim.primary.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "primary" {
  provider         = "aws.${var.region}"
  domain           = "${local.domain}"
  mail_from_domain = "${local.mail_from_domain}"
}

resource "aws_route53_record" "primary_amazonses_mail_from_mx_record" {
  provider = "aws.${var.region}"
  zone_id  = "${local.zone_id}"
  name     = "${local.mail_from_domain}"
  type     = "MX"
  ttl      = "600"
  records  = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

resource "aws_route53_record" "primary_amazonses_mail_from_spf_record" {
  provider = "aws.${var.region}"
  zone_id  = "${local.zone_id}"
  name     = "${local.mail_from_domain}"
  type     = "TXT"
  ttl      = "600"
  records  = ["v=spf1 include:amazonses.com -all"]
}

# module "email_report" {
#   source          = "../aws_email_reports"
#   region          = "${var.region}"
#   domain          = "${var.domain}"
#   reporting_email = "astarcrm@gmail.com"
# }
