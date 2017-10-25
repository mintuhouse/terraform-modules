data "aws_route53_zone" "primary" {
  name = "${var.domain}"
}

resource "aws_route53_record" "primary_improvmx_mx" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${var.domain}"
  type    = "MX"
  ttl     = "3600"
  records = ["10 mx1.improvmx.com", "20 mx2.improvmx.com"]
}
