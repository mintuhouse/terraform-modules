locals {
  wcount            = "${var.whitelabel == "true" ? 4 : 0}"
  whitelabel_domain = "${var.whitelabel_domain == "" ? var.domain : var.whitelabel_domain}"
  self_wcount       = "${((var.whitelabel == "true") && (local.whitelabel_domain == var.domain)) ? 4 : 0}"
}

resource "aws_route53_zone" "primary" {
  name              = "${var.domain}"
  delegation_set_id = "${var.route53_delegation_set_id}"

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  delegated_name_servers = "${sort(aws_route53_zone.primary.name_servers)}"
  ns_name_servers        = "${formatlist("ns%s.%s", list("1","2","3","4"), local.whitelabel_domain)}"

  name_servers = ["${split(",", (var.whitelabel == "true") ?
          join(",", local.ns_name_servers) :
          join(",", local.delegated_name_servers))}"]

  primary_name_server = "${element(local.name_servers, 0)}"
}

# Get IPv4 & IPv6 addresses of name servers from delegation set
data "utils_resolve_ip" "dns" {
  count    = "${local.wcount}"
  dns_name = "${local.delegated_name_servers[count.index]}"
}

resource "aws_route53_record" "A-NS" {
  count   = "${local.self_wcount}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${local.name_servers[count.index]}"
  type    = "A"
  ttl     = "${var.ttl ? var.ttl : 300}"
  records = ["${element(data.utils_resolve_ip.dns.*.ipv4, count.index)}"]
}

resource "aws_route53_record" "AAAA-NS" {
  count   = "${local.self_wcount}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${local.name_servers[count.index]}"
  type    = "AAAA"
  ttl     = "${var.ttl ? var.ttl : 300}"
  records = ["${element(data.utils_resolve_ip.dns.*.ipv6, count.index)}"]
}

resource "aws_route53_record" "primary_ns" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.domain}"
  type    = "NS"
  ttl     = "${var.ttl ? var.ttl : 172800}"
  records = ["${local.name_servers}"]
}

resource "aws_route53_record" "primary_soa" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.domain}"
  type    = "SOA"
  ttl     = "${var.ttl ? var.ttl : 900}"
  records = ["${local.primary_name_server} hostmaster.${var.domain}. 1 7200 900 1209600 ${var.ttl ? var.ttl : 86400}"]
}
