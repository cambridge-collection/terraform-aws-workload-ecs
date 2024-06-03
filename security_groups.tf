data "aws_vpc" "this" {
  id = var.vpc_id
}

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

resource "aws_security_group" "efs" {
  count = var.use_efs_persistence ? 1 : 0

  name        = "${var.name_prefix}-efs"
  description = "Allows access to EFS mount targets for ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-efs"
  }
}

resource "aws_security_group_rule" "efs_ingress_nfs_from_asg" {
  count = var.use_efs_persistence ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  description              = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = aws_security_group.efs.0.id
  source_security_group_id = var.asg_security_group_id
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "efs_ingress_nfs_from_s3" {
  count = var.use_efs_persistence && var.datasync_s3_service_objects_to_efs ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  description              = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = aws_security_group.efs.0.id
  cidr_blocks              = [data.aws_vpc.this.cidr_block]
  ipv6_cidr_blocks         = data.aws_vpc.this.ipv6_cidr_block != "" ? [data.aws_vpc.this.ipv6_cidr_block] : []
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "asg_egress_nfs_to_efs" {
  count = var.use_efs_persistence ? 1 : 0

  type                     = "egress"
  protocol                 = "tcp"
  description              = "ASG Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = var.asg_security_group_id
  source_security_group_id = aws_security_group.efs.0.id
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port
}
