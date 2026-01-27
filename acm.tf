data "aws_route53_zone" "domain" {
  count = var.route53_zone_id != null ? 1 : 0

  zone_id = var.route53_zone_id
}

locals {
  domain_name      = var.domain_name != null ? lower(trim(substr(var.domain_name, -64, -1), ".-")) : ""
  hosted_zone_name = var.route53_zone_id != null ? data.aws_route53_zone.domain.0.name : ""
}

resource "aws_acm_certificate" "this" {
  count = var.acm_create_certificate && var.allow_public_access ? 1 : 0

  domain_name       = local.domain_name
  validation_method = "DNS"
  subject_alternative_names = [
    local.domain_name
  ]

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = endswith(local.domain_name, local.hosted_zone_name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${local.hosted_zone_name}"
    }
  }
}

resource "aws_acm_certificate_validation" "this" {
  count = var.acm_create_certificate && var.allow_public_access ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.0.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation_cname : record.fqdn]

  timeouts {
    create = var.acm_certificate_validation_timeout
  }
}

resource "aws_acm_certificate" "us-east-1" {
  count = var.acm_create_certificate && var.allow_public_access ? 1 : 0

  provider          = aws.us-east-1
  domain_name       = local.domain_name
  validation_method = "DNS"
  subject_alternative_names = [
    local.domain_name
  ]

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = endswith(local.domain_name, local.hosted_zone_name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${local.hosted_zone_name}"
    }
  }
}
