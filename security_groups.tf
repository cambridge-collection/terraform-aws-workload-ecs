resource "aws_security_group_rule" "alb_egress_to_asg" {
  type                     = "egress"
  protocol                 = "tcp"
  description              = "ALB Egress on port ${var.alb_target_group_port} for ${var.name_prefix}"
  security_group_id        = var.alb_security_group_id
  source_security_group_id = var.asg_security_group_id
  from_port                = var.alb_target_group_port
  to_port                  = var.alb_target_group_port
}

resource "aws_security_group_rule" "asg_ingress_from_alb" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "ASG Ingress on port ${var.alb_target_group_port} for ${var.name_prefix}"
  security_group_id        = var.asg_security_group_id
  source_security_group_id = var.alb_security_group_id
  from_port                = var.alb_target_group_port
  to_port                  = var.alb_target_group_port
}

resource "aws_security_group" "private_access" {
  count = var.allow_private_access ? 1 : 0

  name        = "${var.name_prefix}-private-access"
  description = "Allows private access to ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-access"
  }
}

resource "aws_security_group_rule" "asg_ingress_private_access" {
  count = var.allow_private_access ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  description              = "ASG Ingress on port ${var.alb_target_group_port} for ${var.name_prefix}"
  security_group_id        = var.asg_security_group_id
  source_security_group_id = aws_security_group.private_access.0.id
  from_port                = var.alb_target_group_port
  to_port                  = var.alb_target_group_port
}

resource "aws_security_group_rule" "private_access_egress" {
  count = var.allow_private_access ? 1 : 0

  type                     = "egress"
  protocol                 = "tcp"
  description              = "Egress on port ${var.alb_target_group_port} for ${var.name_prefix}"
  security_group_id        = aws_security_group.private_access.0.id
  source_security_group_id = var.asg_security_group_id
  from_port                = var.alb_target_group_port
  to_port                  = var.alb_target_group_port
}
