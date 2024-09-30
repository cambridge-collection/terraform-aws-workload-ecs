data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  provider = aws.us-east-1
  name     = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer" {
  provider = aws.us-east-1
  name     = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "this" {
  provider = aws.us-east-1

  comment         = "${local.domain_name} CloudFront Distribution"
  price_class     = "PriceClass_100"
  enabled         = true
  web_acl_id      = var.cloudfront_waf_acl_arn
  http_version    = "http2"
  is_ipv6_enabled = true
  aliases = [
    local.domain_name
  ]

  origin {
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
    domain_name = var.alb_dns_name
    origin_id   = local.domain_name
    origin_path = ""
  }

  default_cache_behavior {
    allowed_methods          = var.cloudfront_allowed_methods
    cached_methods           = var.cloudfront_cached_methods
    compress                 = true
    smooth_streaming         = false
    target_origin_id         = local.domain_name
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer.id
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.us-east-1.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
