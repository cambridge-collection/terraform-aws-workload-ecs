locals {
  domain_name = lower(trim(substr(var.domain_name, -64, -1), ".-"))
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.acm_create_certificate ? local.domain_name : null
  validation_method         = var.acm_create_certificate ? "DNS" : null
  private_key               = var.acm_certificate_private_key
  certificate_body          = var.acm_certificate_certificate_body
  certificate_chain         = var.acm_certificate_certificate_chain
  subject_alternative_names = var.acm_create_certificate ? [local.domain_name] : null

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = endswith(local.domain_name, data.aws_route53_zone.domain.name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${data.aws_route53_zone.domain.name}"
    }
  }
}

resource "aws_acm_certificate_validation" "this" {
  count = var.acm_create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation_cname : record.fqdn]

  timeouts {
    create = var.acm_certificate_validation_timeout
  }
}

resource "aws_acm_certificate" "us-east-1" {
  provider                  = aws.us-east-1
  domain_name               = var.acm_create_certificate ? local.domain_name : null
  validation_method         = var.acm_create_certificate ? "DNS" : null
  private_key               = var.acm_certificate_private_key
  certificate_body          = var.acm_certificate_certificate_body
  certificate_chain         = var.acm_certificate_certificate_chain
  subject_alternative_names = var.acm_create_certificate ? [local.domain_name] : null

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = endswith(local.domain_name, data.aws_route53_zone.domain.name)
      error_message = "The domain name ${local.domain_name} does not end with Route 53 domain ${data.aws_route53_zone.domain.name}"
    }
  }
}
