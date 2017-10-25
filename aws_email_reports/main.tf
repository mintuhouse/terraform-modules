provider "aws" {
  alias  = "${var.region}"
  region = "${var.region}"
}

data "aws_caller_identity" "current" {
  provider = "aws.${var.region}"
}

data "template_file" "ses_reports" {
  template = "${file("${path.module}/templates/ses-reports.yaml")}"
  vars     = {}
}

locals {
  domain_suffix = "${replace(var.domain, ".", "-")}"
}

resource "aws_cloudformation_stack" "ses_reports" {
  provider     = "aws.${var.region}"
  name         = "ses-reports-${local.domain_suffix}"
  capabilities = ["CAPABILITY_IAM"]

  parameters {
    BucketName       = "ses-reports-${local.domain_suffix}"
    BucketPrefix     = ""
    SourceEmail      = "bounces@${var.domain}"
    DestinationEmail = "${var.reporting_email}"
    Identity         = "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/${var.domain}"
    Frequency        = "cron(00 23 * * ? *)"
  }

  template_body = <<STACK
${data.template_file.ses_reports.rendered}
STACK
}
