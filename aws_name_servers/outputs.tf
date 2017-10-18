output "name_servers" {
  value       = "${aws_route53_delegation_set.main.name_servers}"
  description = "Set the NS records of all your domains in your registrar zone file to `name_servers`"
}

output "dns" {
  value = "${data.external.dns.*.result}"
  description = "Set the glue records for your registrar to following"
}

output "delegation_set_id" {
  value = "${aws_route53_delegation_set.main.id}"
}