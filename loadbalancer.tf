resource "aws_lb_listener_certificate" "this" {
  listener_arn    = var.alb_listener_arn
  certificate_arn = aws_acm_certificate.this.arn

  depends_on = [aws_acm_certificate_validation.this]
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [aws_acm_certificate.this.domain_name]
    }
  }
}

resource "aws_lb_target_group" "this" {
  name = trimsuffix(substr("${var.name_prefix}-alb-tg", 0, 32), "-")
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
  port        = var.alb_target_group_port
  protocol    = var.alb_target_group_protocol
  target_type = var.ecs_network_mode == "awsvpc" ? "ip" : "instance"
  vpc_id      = var.vpc_id
}

resource "random_integer" "green_port" {
  count = var.use_codedeploy ? 1 : 0

  min = 45000
  max = 47000
  keepers = {
    task_def_version = aws_ecs_task_definition.this.revision
  }
}

resource "aws_lb_target_group" "green" {
  count = var.use_codedeploy && var.codedeploy_deployment_type == "BLUE_GREEN" ? 1 : 0

  name = trim(substr("${var.name_prefix}-alb-green-tg", -32, -1), "-")
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
  port        = random_integer.green_port.0.result
  protocol    = var.alb_target_group_protocol
  target_type = var.ecs_network_mode == "awsvpc" ? "ip" : "instance"
  vpc_id      = var.vpc_id
}

# Automatically register autoscaling group instances with load balancer
resource "aws_autoscaling_attachment" "automatic_attachment" {
  count = var.ecs_network_mode == "awsvpc" ? 0 : 1 # NOTE autoscaling attachments only support instance targets

  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

resource "aws_autoscaling_attachment" "green" {
  count = var.use_codedeploy && var.codedeploy_deployment_type == "BLUE_GREEN" && var.ecs_network_mode != "awsvpc" ? 1 : 0 # NOTE autoscaling attachments only support instance targets

  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.green.0.arn
}
