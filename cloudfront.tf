data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  count = var.cloudfront_distribution_create && var.allow_public_access ? 1 : 0

  provider = aws.us-east-1
  name     = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer" {
  count = var.cloudfront_distribution_create && var.allow_public_access ? 1 : 0

  provider = aws.us-east-1
  name     = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "this" {
  count = var.cloudfront_distribution_create && var.allow_public_access ? 1 : 0

  provider = aws.us-east-1

  comment         = "${local.domain_name} CloudFront Distribution"
  price_class     = "PriceClass_100"
  enabled         = true
  web_acl_id      = var.cloudfront_waf_acl_arn
  http_version    = "http2"
  is_ipv6_enabled = true
  aliases         = concat([local.domain_name], var.alternative_domain_names)

  origin {
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = var.cloudfront_origin_read_timeout
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
    connection_attempts = var.cloudfront_origin_connection_attempts
    domain_name         = var.alb_dns_name
    origin_id           = local.domain_name
    origin_path         = ""
  }

  dynamic "origin" {
    for_each = { for additional_origin in var.cloudfront_additional_origins : additional_origin.id => additional_origin }
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.id
      origin_access_control_id = origin.value.access_control_id
      origin_path              = origin.value.path
    }
  }

  default_cache_behavior {
    allowed_methods          = var.cloudfront_allowed_methods
    cached_methods           = var.cloudfront_cached_methods
    compress                 = true
    smooth_streaming         = false
    target_origin_id         = local.domain_name
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.0.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer.0.id

    dynamic "function_association" {
      for_each = var.cloudfront_viewer_request_function_arn != null ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = var.cloudfront_viewer_request_function_arn
      }
    }

    dynamic "function_association" {
      for_each = var.cloudfront_viewer_response_function_arn != null ? [1] : []
      content {
        event_type   = "viewer-response"
        function_arn = var.cloudfront_viewer_response_function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = { for ocb in var.cloudfront_ordered_cache_behaviors : ocb.target_origin_id => ocb }
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      cache_policy_id        = coalesce(ordered_cache_behavior.value.cache_policy_id, data.aws_cloudfront_cache_policy.managed_caching_disabled.0.id)
      compress               = ordered_cache_behavior.value.compress
    }
  }

  dynamic "custom_error_response" {
    for_each = { for response in var.cloudfront_custom_error_responses : response.error_code => response }
    content {
      error_code            = custom_error_response.value.error_code
      response_page_path    = custom_error_response.value.response_page_path
      response_code         = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_create_certificate ? aws_acm_certificate.us-east-1.0.arn : var.acm_certificate_arn_us-east-1
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "logging_config" {
    for_each = var.cloudfront_access_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = var.cloudfront_access_logging_bucket
      prefix          = var.name_prefix
    }
  }
}
