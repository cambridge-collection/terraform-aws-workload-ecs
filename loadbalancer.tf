resource "aws_lb_listener_certificate" "this" {
  count = var.alb_listener_certificate_create && var.allow_public_access ? 1 : 0

  listener_arn    = var.alb_listener_arn
  certificate_arn = var.acm_create_certificate ? aws_acm_certificate_validation.this.0.certificate_arn : var.acm_certificate_arn
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.alb_listener_rule_create && var.allow_public_access ? { for target in var.alb_target_group_settings : target.name => target } : {}

  listener_arn = var.alb_listener_arn
  priority     = each.value.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    host_header {
      values = concat([local.domain_name], var.alternative_domain_names)
    }
  }

  dynamic "condition" {
    for_each = length(each.value.listener_rule_path_patterns) > 0 ? [1] : []
    content {
      path_pattern {
        values = each.value.listener_rule_path_patterns
      }
    }
  }

  tags = {
    Name = format("%s-fwd-to-tg", each.key)
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.allow_public_access ? { for target in var.alb_target_group_settings : target.name => target } : {}

  name                 = trimprefix(substr("${each.key}-alb-tg", -32, -1), "-")
  port                 = each.value.port
  protocol             = var.alb_target_group_protocol
  target_type          = var.ecs_network_mode == "awsvpc" ? "ip" : "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = var.alb_target_group_deregistration_delay
  slow_start           = var.alb_target_group_slow_start

  health_check {
    interval            = var.alb_target_group_health_check_interval
    path                = each.value.health_check_path
    port                = "traffic-port" # Same as target group port
    protocol            = var.alb_target_group_protocol
    timeout             = var.alb_target_group_health_check_timeout
    unhealthy_threshold = var.alb_target_group_health_check_unhealthy_threshold
    healthy_threshold   = var.alb_target_group_health_check_healthy_threshold
    matcher             = each.value.health_check_expected_status
  }
}

# Automatically register autoscaling group instances with load balancer
resource "aws_autoscaling_attachment" "automatic_attachment" {
  count = var.allow_public_access && var.ecs_network_mode != "awsvpc" ? length(var.alb_target_group_settings) : 0 # NOTE autoscaling attachments only support instance targets

  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this[var.alb_target_group_settings[count.index].name].arn
}
