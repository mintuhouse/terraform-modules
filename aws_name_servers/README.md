# Usage
* If `var.whitelabel` is set as `"true"`, you also need to [add glue records to your registrar](#modifying-glue-records)
* Note: There is a minor bug with the current implementation sometimes. If you get an error, run the module with whitelabel=false and then change to true.

### Modifying Glue Records
Refer the documentation for your registrar
* [AWS](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-name-servers-glue-records.html)
* [GoDaddy](https://in.godaddy.com/help/add-my-own-host-names-as-nameservers-12320)

Add both IPv4 and IPv6 address

**WARNING**: Don't make a mistake in assigning wrong IPs. Since the default TTL is 1 hour, it may be a while for which your site would be unavailable. A better approach would be to set the ttl to 60s initially and increase it after you confirm that everything is working normally

## References
* [NS and SOA Resource Record on AWS](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html)
* [White Label Name Servers on AWS](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/white-label-name-servers.html)