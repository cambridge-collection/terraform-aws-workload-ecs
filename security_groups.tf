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

# NOTE this may be needed where the security group owned by an external client
# (var.ingress_security_group_id) has restricted outbound rules
resource "aws_security_group_rule" "private_access_egress" {
  count = var.allow_private_access && var.update_ingress_security_group ? 1 : 0

  type                     = "egress"
  protocol                 = "tcp"
  description              = "Egress on port ${var.alb_target_group_port} on ${var.ingress_security_group_id}"
  security_group_id        = var.ingress_security_group_id
  source_security_group_id = var.asg_security_group_id
  from_port                = var.alb_target_group_port
  to_port                  = var.alb_target_group_port
}

resource "aws_security_group" "efs" {
  count = var.efs_create_file_system ? 1 : 0

  name        = "${var.name_prefix}-efs"
  description = "Allows access to EFS mount targets for ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-efs"
  }
}

resource "aws_security_group_rule" "efs_ingress_nfs_from_asg" {
  count = var.efs_create_file_system ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  description              = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = aws_security_group.efs.0.id
  source_security_group_id = var.asg_security_group_id
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "efs_ingress_nfs_from_vpc" {
  count = var.efs_create_file_system && var.datasync_s3_objects_to_efs ? 1 : 0

  type              = "ingress"
  protocol          = "tcp"
  description       = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id = aws_security_group.efs.0.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  ipv6_cidr_blocks  = data.aws_vpc.this.ipv6_cidr_block != "" ? [data.aws_vpc.this.ipv6_cidr_block] : []
  from_port         = var.efs_nfs_mount_port
  to_port           = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "efs_egress_nfs_to_vpc" {
  count = var.efs_create_file_system && var.datasync_s3_objects_to_efs ? 1 : 0

  type              = "egress"
  protocol          = "tcp"
  description       = "EFS Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id = aws_security_group.efs.0.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  ipv6_cidr_blocks  = data.aws_vpc.this.ipv6_cidr_block != "" ? [data.aws_vpc.this.ipv6_cidr_block] : []
  from_port         = var.efs_nfs_mount_port
  to_port           = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "asg_egress_nfs_to_efs" {
  count = var.efs_create_file_system ? 1 : 0

  type                     = "egress"
  protocol                 = "tcp"
  description              = "ASG Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = var.asg_security_group_id
  source_security_group_id = aws_security_group.efs.0.id
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port
}

resource "aws_security_group_rule" "asg_egress_nfs_to_existing_efs" {
  count = var.efs_use_existing_filesystem ? 1 : 0

  type                     = "egress"
  protocol                 = "tcp"
  description              = "ASG Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id        = var.asg_security_group_id
  source_security_group_id = var.efs_security_group_id
  from_port                = var.efs_nfs_mount_port
  to_port                  = var.efs_nfs_mount_port

  lifecycle {
    precondition {
      condition     = var.efs_security_group_id != null
      error_message = "To use an existing filesystem the input efs_security_group_id must be provided."
    }
  }
}
