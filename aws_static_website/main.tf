# Get root domain of subdomain
data "utils_root_domain" "subdomain" {
  domain = "${var.subdomain}"
}

locals {
  domain = "${data.utils_root_domain.subdomain.name}"
}

# Get Route53 Zone for the domain
data "aws_route53_zone" "domain" {
  name = "${local.domain}"
}

# Create bucket which hosts the static files
locals {
  bucket_name = "website-${replace("${var.subdomain}",".","-")}"
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/templates/website_redirect_bucket_policy.json")}"

  vars {
    bucket = "${local.bucket_name}"
  }
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${local.bucket_name}"
  policy = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
  }

  logging {
    target_bucket = "${var.log_bucket}"
    target_prefix = "s3-${local.bucket_name}/"
  }

  tags = "${var.tags}"
}

# Create a CloudFront distribution for the bucket
locals {
  bucket_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
  cdn_name         = "${local.bucket_name}"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled             = true
  comment             = "Serves ${var.subdomain}"
  aliases             = ["${var.subdomain}"]
  price_class         = "PriceClass_All"
  default_root_object = "${var.index_document}"
  is_ipv6_enabled     = true

  retain_on_delete = true # Avoid blocking of CDN modifications during deployment by disabling instead of destroying on delete

  default_cache_behavior {
    target_origin_id       = "${local.bucket_origin_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = "0"
    default_ttl = "10"  //TODO: 3600
    max_ttl     = "100" //86400
  }

  logging_config {
    bucket = "${var.log_bucket}.s3.amazonaws.com"
    prefix = "cf-${local.cdn_name}/"
  }

  origin {
    origin_id   = "${local.bucket_origin_id}"
    domain_name = "${aws_s3_bucket.website_bucket.website_endpoint}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "404"
    response_page_path    = "/${var.error_document}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  tags = "${var.tags}"
}

# Create Route53 ALIAS record for subdomain
resource "aws_route53_record" "cdn-alias" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${var.subdomain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
