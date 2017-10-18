#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Extract "dnsname" argument from the input into DNSNAME shell variable
# jq will ensure that the values are properly quoted and escaped for consumption by the shell.
eval "$(jq -r '@sh "DNSNAME=\(.dnsname) NS=\(.nsname)"')"

# Placeholder for whatever data-fetching logic your script implements
IPv4=$(dig A $DNSNAME +short)
IPv6=$(dig AAAA $DNSNAME +short)


# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
jq -n --arg ipv4 "$IPv4" --arg ipv6 "$IPv6" --arg NS "$NS" '{"ns":$NS, "ipv4":$ipv4, "ipv6":$ipv6}'