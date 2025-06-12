locals {
  domain_name = lower(trim(substr(var.domain_name, -64, -1), ".-"))
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
      condition     = endswith(local.domain_name, data.aws_route53_zone.domain.name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${data.aws_route53_zone.domain.name}"
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
      condition     = endswith(local.domain_name, data.aws_route53_zone.domain.name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${data.aws_route53_zone.domain.name}"
    }
  }
}
