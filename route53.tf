data "aws_route53_zone" "domain" {
  zone_id = var.route53_zone_id
}

resource "aws_route53_record" "cloudfront_alias" {
  count = var.route53_create_cloudfront_alias_record && var.allow_public_access ? 1 : 0

  name = local.domain_name

  type = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.0.domain_name
    zone_id                = aws_cloudfront_distribution.this.0.hosted_zone_id
    evaluate_target_health = false
  }
  zone_id = data.aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "acm_validation_cname" {
  for_each = var.acm_create_certificate && var.allow_public_access ? {
    for dvo in aws_acm_certificate.this.0.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}
