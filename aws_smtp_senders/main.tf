resource "aws_iam_group" "smtp_senders" {
  name = "smtp_senders_${var.domain}"
  path = "/smtp/"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "smtp_send_email" {
  description = "Allow smtp users to send email"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action":["ses:SendEmail", "ses:SendRawEmail"],
      "Resource": "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/${var.domain}",
      "Condition": {
        "StringEquals": {
          "ses:FromAddress": "$${aws:username}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "smtp_send_email-attach" {
  group      = "${aws_iam_group.smtp_senders.name}"
  policy_arn = "${aws_iam_policy.smtp_send_email.arn}"
}

locals {
  email_count = "${length(split(",", var.smtp_email_ids))}"
}

data "null_data_source" "email_ids" {
  count = "${local.email_count}"

  inputs = {
    value = "${element(split(",", var.smtp_email_ids), count.index)}@${var.domain}"
  }
}

resource "aws_iam_user" "smtp_user" {
  count = "${local.email_count}"
  name  = "${data.null_data_source.email_ids.*.outputs.value[count.index]}"
  path  = "/smtp/"
}

resource "aws_iam_access_key" "smtp_user" {
  count = "${local.email_count}"
  user  = "${aws_iam_user.smtp_user.*.name[count.index]}"
}

resource "aws_iam_group_membership" "smtp_senders" {
  name  = "smtp-senders"
  users = ["${aws_iam_user.smtp_user.*.name}"]
  group = "${aws_iam_group.smtp_senders.name}"
}

data "null_data_source" "smtp_credentials" {
  count = "${local.email_count}"

  inputs = {
    email_id    = "${aws_iam_access_key.smtp_user.*.user[count.index]}"
    username    = "${aws_iam_access_key.smtp_user.*.id[count.index]}"
    password    = "${aws_iam_access_key.smtp_user.*.ses_smtp_password[count.index]}"
    smtp_server = "email-smtp.${var.region}.amazonaws.com"
    smtp_port   = "587"
  }
}
