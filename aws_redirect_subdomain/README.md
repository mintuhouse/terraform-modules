301 (Permanent) Redirect

`aws acm request-certificate --region us-east-1 --domain-name "*.astarcrm.com" --subject-alternative-names "astarcrm.com" "astarcrm.in" "*.astarcrm.in" --idempotency-token random
`
And approve the certificate via the link sent in email (one email per subdomain)