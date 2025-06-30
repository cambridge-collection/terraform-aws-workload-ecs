resource "aws_lb_listener_certificate" "this" {
  count = var.alb_listener_certificate_create && var.allow_public_access ? 1 : 0

  listener_arn    = var.alb_listener_arn
  certificate_arn = var.acm_create_certificate ? aws_acm_certificate_validation.this.0.certificate_arn : var.acm_certificate_arn
}

resource "aws_lb_listener_rule" "this" {
  count = var.alb_listener_rule_create && var.allow_public_access ? 1 : 0

  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority

  dynamic "action" {
    for_each = aws_lb_target_group.this

    content {
      type             = "forward"
      target_group_arn = action.value.arn
    }
  }

  condition {
    host_header {
      values = concat([local.domain_name], var.alternative_domain_names)
    }
  }

  dynamic "condition" {
    for_each = length(var.alb_listener_rule_path_patterns) > 0 ? [1] : []
    content {
      path_pattern {
        values = var.alb_listener_rule_path_patterns
      }
    }
  }

  tags = {
    Name = format("%s-fwd-to-tg", var.name_prefix)
  }
}

resource "aws_lb_target_group" "this" {
  # count = var.allow_public_access ? length(var.alb_target_group_ports) : 0
  for_each = { for target in var.alb_target_group_ports : target.name => target.port }

  name                 = trimprefix(substr("${var.name_prefix}-alb-tg-${each.key}", -32, -1), "-")
  port                 = each.value
  protocol             = var.alb_target_group_protocol
  target_type          = var.ecs_network_mode == "awsvpc" ? "ip" : "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = var.alb_target_group_deregistration_delay
  slow_start           = var.alb_target_group_slow_start

  health_check {
    interval            = var.alb_target_group_health_check_interval
    path                = var.alb_target_group_health_check_path
    port                = "traffic-port" # Same as target group port
    protocol            = var.alb_target_group_protocol
    timeout             = var.alb_target_group_health_check_timeout
    unhealthy_threshold = var.alb_target_group_health_check_unhealthy_threshold
    healthy_threshold   = var.alb_target_group_health_check_healthy_threshold
    matcher             = var.alb_target_group_health_check_status_code
  }
}

# Automatically register autoscaling group instances with load balancer
resource "aws_autoscaling_attachment" "automatic_attachment" {
  count = var.allow_public_access && var.ecs_network_mode != "awsvpc" ? length(var.alb_target_group_ports) : 0 # NOTE autoscaling attachments only support instance targets

  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this[var.alb_target_group_ports[count.index].name].arn
}
