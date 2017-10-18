output "name_servers" {
  value       = "${local.name_servers}"
  description = "Set the NS records of all your domains in your registrar zone file to `name_servers`"
}

output "dns" {
  value       = "${data.external.dns.*.result}"
  description = "Set the glue records for your registrar to following"
}
