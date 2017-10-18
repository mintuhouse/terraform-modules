locals {
  wcount            = "${var.whitelabel == "true" ? 4 : 0}"
  whitelabel_domain = "${var.whitelabel_domain == "" ? var.domain : var.whitelabel_domain}"
  self_wcount       = "${((var.whitelabel == "true") && (local.whitelabel_domain == var.domain)) ? 4 : 0}"
}

resource "aws_route53_zone" "primary" {
  name              = "${var.domain}"
  delegation_set_id = "${var.route53_delegation_set_id}"
}

data "null_data_source" "name_servers" {
  count = "${local.wcount}"

  inputs = {
    value = "ns${count.index+1}.${local.whitelabel_domain}"
  }
}

locals {
  name_servers = ["${split(",", (var.whitelabel == "true") ?
          join(",", data.null_data_source.name_servers.*.outputs.value) :
          join(",", aws_route53_zone.primary.name_servers))}"]

  primary_name_server = "${element(local.name_servers, 0)}"
  # depends_on          = ["aws_route53_zone.primary", "data.null_data_source.name_servers"]
}

# Get IPv4 & IPv6 addresses of name servers from delegation set
data "external" "dns" {
  count   = "${local.wcount}"
  program = ["bash", "${path.module}/dns-to-ip.sh"]

  query = {
    dnsname = "${aws_route53_zone.primary.name_servers[count.index]}"
    nsname  = "${local.name_servers[count.index]}"
  }

  # depends_on = ["aws_route53_zone.primary", "data.null_data_source.name_servers"]
}

resource "aws_route53_record" "A-NS" {
  count      = "${local.self_wcount}"
  zone_id    = "${aws_route53_zone.primary.zone_id}"
  name       = "${local.name_servers[count.index]}"
  type       = "A"
  ttl        = "${var.ttl ? var.ttl : 300}"
  records    = ["${element(data.external.dns.*.result.ipv4, count.index)}"]
  # depends_on = ["data.external.dns"]
}

resource "aws_route53_record" "AAAA-NS" {
  count      = "${local.self_wcount}"
  zone_id    = "${aws_route53_zone.primary.zone_id}"
  name       = "${local.name_servers[count.index]}"
  type       = "AAAA"
  ttl        = "${var.ttl ? var.ttl : 300}"
  records    = ["${element(data.external.dns.*.result.ipv6, count.index)}"]
  # depends_on = ["data.external.dns"]
}

resource "aws_route53_record" "primary_ns" {
  zone_id    = "${aws_route53_zone.primary.zone_id}"
  name       = "${var.domain}"
  type       = "NS"
  ttl        = "${var.ttl ? var.ttl : 172800}"
  records    = ["${local.name_servers}"]
  # depends_on = ["aws_route53_zone.primary", "data.null_data_source.name_servers"]
}

resource "aws_route53_record" "primary_soa" {
  zone_id    = "${aws_route53_zone.primary.zone_id}"
  name       = "${var.domain}"
  type       = "SOA"
  ttl        = "${var.ttl ? var.ttl : 900}"
  records    = ["${local.primary_name_server} hostmaster.${var.domain}. 1 7200 900 1209600 ${var.ttl ? var.ttl : 86400}"]
  # depends_on = ["aws_route53_zone.primary", "data.null_data_source.name_servers"]
}
