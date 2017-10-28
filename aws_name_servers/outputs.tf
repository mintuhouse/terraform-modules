output "name_servers" {
  value       = "${local.name_servers}"
  description = "Set the NS records of all your domains in your registrar zone file to `name_servers`"
}

locals {
  dns0 = "${map(
    "ns", local.name_servers[0],
    "dnsname", local.delegated_name_servers[0],
    "ipv4", element(data.utils_resolve_ip.dns.*.ipv4, 0),
    "ipv6", element(data.utils_resolve_ip.dns.*.ipv6, 0)
  )}"

  dns1 = "${map(
    "ns", local.name_servers[1],
    "dnsname", local.delegated_name_servers[1],
    "ipv4", element(data.utils_resolve_ip.dns.*.ipv4, 1),
    "ipv6", element(data.utils_resolve_ip.dns.*.ipv6, 1)
  )}"

  dns2 = "${map(
    "ns", local.name_servers[2],
    "dnsname", local.delegated_name_servers[2],
    "ipv4", element(data.utils_resolve_ip.dns.*.ipv4, 2),
    "ipv6", element(data.utils_resolve_ip.dns.*.ipv6, 2)
  )}"

  dns3 = "${map(
    "ns", local.name_servers[3],
    "dnsname", local.delegated_name_servers[3],
    "ipv4", element(data.utils_resolve_ip.dns.*.ipv4, 3),
    "ipv6", element(data.utils_resolve_ip.dns.*.ipv6, 3)
  )}"
}

output "dns" {
  description = "Set the glue records for your registrar to following"

  value = "${list(local.dns0, local.dns1, local.dns2, local.dns3)}"
}
