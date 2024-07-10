resource "aws_wafv2_ip_set" "this" {
  count = length(var.waf_ip_set_addresses) > 0 && var.create_waf ? 1 : 0

  name               = "${var.name_prefix}-waf-ip-set"
  provider           = aws.us-east-1
  description        = "Managed by Terraform"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.waf_ip_set_addresses
}

resource "aws_wafv2_web_acl" "this" {
  count = var.create_waf ? 1 : 0

  name        = "${var.name_prefix}-waf-web-acl"
  provider    = aws.us-east-1
  description = "Managed by Terraform for ${var.name_prefix}"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"
          action_to_use {
            allow {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = length(var.waf_ip_set_addresses) > 0 ? [1] : []

    content {
      name     = "${var.name_prefix}-waf-web-acl-rule-ip-set"
      priority = 3

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.this.0.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name_prefix}-waf-web-acl-rule-ip-set"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = toset(var.waf_additional_rules)

    content {
      name     = "${var.name_prefix}-waf-rule-${length(var.waf_ip_set_addresses) > 0 ? index(var.waf_additional_rules, rule.value) + 4 : index(var.waf_additional_rules, rule.value) + 3}"
      priority = length(var.waf_ip_set_addresses) > 0 ? index(var.waf_additional_rules, rule.value) + 4 : index(var.waf_additional_rules, rule.value) + 3

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name_prefix}-waf-metric-${length(var.waf_ip_set_addresses) > 0 ? index(var.waf_additional_rules, rule.value) + 4 : index(var.waf_additional_rules, rule.value) + 3}"
        sampled_requests_enabled   = true
      }

      dynamic "statement" {
        for_each = try(rule.value.statement, [])
        content {
          dynamic "byte_match_statement" {
            for_each = try(statement.value.byte_match_statement, [])
            content {
              search_string         = try(byte_match_statement.value.search_string, null)
              positional_constraint = try(byte_match_statement.value.positional_constraint, null)

              dynamic "field_to_match" {
                for_each = try(byte_match_statement.value.field_to_match, [])
                content {
                  dynamic "all_query_arguments" {
                    for_each = try(field_to_match.value.all_query_arguments, false) ? [1] : []
                    content {}
                  }

                  dynamic "body" {
                    for_each = try(field_to_match.value.body, [])
                    content {
                      oversize_handling = try(body.value.oversize_handling, null)
                    }
                  }

                  dynamic "cookies" {
                    for_each = try(field_to_match.value.cookies, [])
                    content {
                      match_pattern     = try(cookies.value.match_pattern, null)
                      match_scope       = try(cookies.value.match_scope, null)
                      oversize_handling = try(cookies.value.oversize_handling, null)
                    }
                  }

                  dynamic "header_order" {
                    for_each = try(field_to_match.value.header_order, [])
                    content {
                      oversize_handling = try(header_order.value.oversize_handling, null)
                    }
                  }

                  dynamic "headers" {
                    for_each = try(field_to_match.value.headers, [])
                    content {
                      match_scope       = try(headers.value.match_scope, null)
                      oversize_handling = try(headers.value.oversize_handling, null)
                      dynamic "match_pattern" {
                        for_each = try(headers.value.match_pattern, [])
                        content {
                          included_headers = try(match_pattern.value.included_headers, [])
                          excluded_headers = try(match_pattern.value.excluded_headers, [])
                          dynamic "all" {
                            for_each = try(match_pattern.value.all, false) ? [1] : []
                            content {}
                          }
                        }
                      }
                    }
                  }

                  dynamic "ja3_fingerprint" {
                    for_each = try(field_to_match.value.ja3_fingerprint, [])
                    content {
                      fallback_behavior = try(ja3_fingerprint.value.fallback_behavior, null)
                    }
                  }

                  dynamic "json_body" {
                    for_each = try(field_to_match.value.json_body, [])
                    content {
                      invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                      match_scope               = try(json_body.value.match_scope, null)
                      oversize_handling         = try(json_body.value.oversize_handling, null)
                      dynamic "match_pattern" {
                        for_each = try(json_body.value.match_pattern, null)
                        content {
                          included_paths = try(match_pattern.value.included_paths, [])
                          dynamic "all" {
                            for_each = try(match_pattern.value.all, false) ? [1] : []
                            content {}
                          }
                        }
                      }
                    }
                  }

                  dynamic "method" {
                    for_each = try(field_to_match.value.method, false) ? [1] : []
                    content {}
                  }

                  dynamic "query_string" {
                    for_each = try(field_to_match.value.query_string, false) ? [1] : []
                    content {}
                  }

                  dynamic "single_header" {
                    for_each = try(field_to_match.value.single_header, [])
                    content {
                      name = try(single_header.value.name, null)
                    }
                  }

                  dynamic "single_query_argument" {
                    for_each = try(field_to_match.value.single_query_argument, [])
                    content {
                      name = try(single_query_argument.value.name, null)
                    }
                  }

                  dynamic "uri_path" {
                    for_each = try(field_to_match.value.uri_path, false) ? [1] : []
                    content {}
                  }
                }
              }

              dynamic "text_transformation" {
                for_each = try(byte_match_statement.value.text_transformation, [])
                content {
                  priority = try(text_transformation.value.priority, null)
                  type     = try(text_transformation.value.type, null)
                }
              }
            }
          }

          dynamic "rate_based_statement" {
            for_each = try(statement.value.rate_based_statement, [])
            content {
              aggregate_key_type    = try(rate_based_statement.value.aggregate_key_type, [])
              evaluation_window_sec = try(rate_based_statement.value.evaluation_window_sec, [])
              limit                 = try(rate_based_statement.value.limit, [])

              dynamic "custom_key" {
                for_each = try(rate_based_statement.value.custom_key, [])
                content {
                  dynamic "cookie" {
                    for_each = try(custom_key.value.cookie, [])
                    content {
                      name = try(cookie.value.name, null)
                      dynamic "text_transformation" {
                        for_each = try(cookie.value.text_transformation, [])
                        content {
                          priority = try(text_transformation.value.priority, null)
                          type     = try(text_transformation.value.type, null)
                        }
                      }
                    }
                  }

                  dynamic "forwarded_ip" {
                    for_each = try(custom_key.value.forwarded_ip, false) ? [1] : []
                    content {}
                  }

                  dynamic "http_method" {
                    for_each = try(custom_key.value.http_method, false) ? [1] : []
                    content {}
                  }

                  dynamic "header" {
                    for_each = try(custom_key.value.header, [])
                    content {
                      name = try(header.value.name, null)
                      dynamic "text_transformation" {
                        for_each = try(header.value.text_transformation, [])
                        content {
                          priority = try(text_transformation.value.priority, null)
                          type     = try(text_transformation.value.type, null)
                        }
                      }
                    }
                  }

                  dynamic "ip" {
                    for_each = try(custom_key.value.ip, false) ? [1] : []
                    content {}
                  }

                  dynamic "label_namespace" {
                    for_each = try(custom_key.value.label_namespace, [])
                    content {
                      namespace = try(label_namespace.value.namespace)
                    }
                  }

                  dynamic "query_argument" {
                    for_each = try(custom_key.value.query_argument, [])
                    content {
                      name = try(query_argument.value.name, null)
                      dynamic "text_transformation" {
                        for_each = try(query_argument.value.text_transformation, [])
                        content {
                          priority = try(text_transformation.value.priority, null)
                          type     = try(text_transformation.value.type, null)
                        }
                      }
                    }
                  }

                  dynamic "query_string" {
                    for_each = try(custom_key.value.query_string, [])
                    content {
                      dynamic "text_transformation" {
                        for_each = try(query_string.value.text_transformation, [])
                        content {
                          priority = try(text_transformation.value.priority, null)
                          type     = try(text_transformation.value.type, null)
                        }
                      }
                    }
                  }

                  dynamic "uri_path" {
                    for_each = try(custom_key.value.uri_path, [])
                    content {
                      dynamic "text_transformation" {
                        for_each = try(uri_path.value.text_transformation, [])
                        content {
                          priority = try(text_transformation.value.priority, null)
                          type     = try(text_transformation.value.type, null)
                        }
                      }
                    }
                  }
                }
              }

              dynamic "forwarded_ip_config" {
                for_each = try(rate_based_statement.value.forwarded_ip_config, [])
                content {
                  fallback_behavior = try(forwarded_ip_config.value.fallback_behavior, null)
                  header_name       = try(forwarded_ip_config.value.header_name, null)
                }
              }

              # NOTE scope_down_statement not supported as it supports further nesting of statement blocks
            }
          }

          dynamic "regex_match_statement" {
            for_each = try(statement.value.regex_match_statement, [])
            content {
              regex_string = try(regex_match_statement.value.regex_string, null)

              dynamic "field_to_match" {
                for_each = try(regex_match_statement.value.field_to_match, [])
                content {
                  all_query_arguments = try(field_to_match.value.all_query_arguments, null)
                  method              = try(field_to_match.value.method, null)
                  query_string        = try(field_to_match.value.query_string, null)
                  uri_path            = try(field_to_match.value.uri_path, null)

                  dynamic "body" {
                    for_each = try(field_to_match.value.body, [])
                    content {
                      oversize_handling = try(body.value.oversize_handling, null)
                    }
                  }

                  dynamic "cookies" {
                    for_each = try(field_to_match.value.cookies, [])
                    content {
                      match_pattern     = try(cookies.value.match_pattern, null)
                      match_scope       = try(cookies.value.match_scope, null)
                      oversize_handling = try(cookies.value.oversize_handling, null)
                    }
                  }

                  dynamic "header_order" {
                    for_each = try(field_to_match.value.header_order, [])
                    content {
                      oversize_handling = try(header_order.value.oversize_handling, null)
                    }
                  }

                  dynamic "headers" {
                    for_each = try(field_to_match.value.headers, [])
                    content {
                      match_scope       = try(headers.value.match_scope, null)
                      oversize_handling = try(headers.value.oversize_handling, null)
                      dynamic "match_pattern" {
                        for_each = try(headers.value.match_pattern, [])
                        content {
                          included_headers = try(match_pattern.value.included_headers, [])
                          excluded_headers = try(match_pattern.value.excluded_headers, [])
                          dynamic "all" {
                            for_each = try(match_pattern.value.all, false) ? [1] : []
                            content {}
                          }
                        }
                      }
                    }
                  }

                  dynamic "ja3_fingerprint" {
                    for_each = try(field_to_match.value.ja3_fingerprint, [])
                    content {
                      fallback_behavior = try(ja3_fingerprint.value.fallback_behavior, null)
                    }
                  }

                  dynamic "json_body" {
                    for_each = try(field_to_match.value.json_body, [])
                    content {
                      invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                      match_scope               = try(json_body.value.match_scope, null)
                      oversize_handling         = try(json_body.value.oversize_handling, null)
                      dynamic "match_pattern" {
                        for_each = try(json_body.value.match_pattern, null)
                        content {
                          included_paths = try(match_pattern.value.included_paths, [])
                          dynamic "all" {
                            for_each = try(match_pattern.value.all, false) ? [1] : []
                            content {}
                          }
                        }
                      }
                    }
                  }

                  dynamic "single_header" {
                    for_each = try(field_to_match.value.single_header, [])
                    content {
                      name = try(single_header.value.name, null)
                    }
                  }

                  dynamic "single_query_argument" {
                    for_each = try(field_to_match.value.single_query_argument, [])
                    content {
                      name = try(single_query_argument.value.name, null)
                    }
                  }
                }
              }

              dynamic "text_transformation" {
                for_each = try(regex_match_statement.value.text_transformation, [])
                content {
                  priority = try(text_transformation.value.priority, null)
                  type     = try(text_transformation.value.type, null)
                }
              }
            }
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf-web-acl-no-rule"
    sampled_requests_enabled   = true
  }
}
