data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_to_asg" {
  count = var.allow_public_access ? length(var.alb_target_group_ports) : 0

  ip_protocol                  = "tcp"
  description                  = "ALB Egress on port ${var.alb_target_group_ports[count.index]} for ${var.name_prefix}"
  security_group_id            = var.alb_security_group_id
  referenced_security_group_id = var.asg_security_group_id
  from_port                    = var.alb_target_group_ports[count.index]
  to_port                      = var.alb_target_group_ports[count.index]

  tags = {
    Name = format("alb-egress-to-asg-%s", var.alb_target_group_ports[count.index])
  }
}

resource "aws_vpc_security_group_ingress_rule" "asg_ingress_from_alb" {
  count = var.allow_public_access ? length(var.alb_target_group_ports) : 0

  ip_protocol                  = "tcp"
  description                  = "ASG Ingress on port ${var.alb_target_group_ports[count.index]} for ${var.name_prefix}"
  security_group_id            = var.asg_security_group_id
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = var.alb_target_group_ports[count.index]
  to_port                      = var.alb_target_group_ports[count.index]

  tags = {
    Name = format("asg-ingress-from-alb-%s", var.alb_target_group_ports[count.index])
  }
}

# NOTE this may be needed where the security group owned by an external client
# (var.ingress_security_group_id) has restricted outbound rules
resource "aws_vpc_security_group_egress_rule" "private_access_egress" {
  count = var.allow_private_access && var.update_asg_security_group_to_access_service ? length(var.alb_target_group_ports) : 0

  ip_protocol                  = "tcp"
  description                  = "Egress on port ${var.alb_target_group_ports[count.index]} to ${var.ingress_security_group_id}"
  security_group_id            = var.asg_security_group_id
  referenced_security_group_id = var.ingress_security_group_id
  from_port                    = var.alb_target_group_ports[count.index]
  to_port                      = var.alb_target_group_ports[count.index]

  tags = {
    Name = format("asg-egress-private-access-%s", var.alb_target_group_ports[count.index])
  }
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

resource "aws_vpc_security_group_ingress_rule" "efs_ingress_nfs_from_asg" {
  count = var.efs_create_file_system ? 1 : 0

  ip_protocol                  = "tcp"
  description                  = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id            = aws_security_group.efs.0.id
  referenced_security_group_id = var.asg_security_group_id
  from_port                    = var.efs_nfs_mount_port
  to_port                      = var.efs_nfs_mount_port

  tags = {
    Name = format("efs-ingress-from-asg-%s", var.efs_nfs_mount_port)
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_ingress_nfs_from_vpc" {
  count = var.efs_create_file_system && var.datasync_s3_objects_to_efs ? 1 : 0

  ip_protocol       = "tcp"
  description       = "EFS Ingress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id = aws_security_group.efs.0.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  cidr_ipv6         = data.aws_vpc.this.ipv6_cidr_block != "" ? data.aws_vpc.this.ipv6_cidr_block : null
  from_port         = var.efs_nfs_mount_port
  to_port           = var.efs_nfs_mount_port

  tags = {
    Name = format("efs-ingress-from-vpc-%s", var.efs_nfs_mount_port)
  }
}

resource "aws_vpc_security_group_egress_rule" "efs_egress_nfs_to_vpc" {
  count = var.efs_create_file_system && var.datasync_s3_objects_to_efs ? 1 : 0

  ip_protocol       = "tcp"
  description       = "EFS Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id = aws_security_group.efs.0.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  cidr_ipv6         = data.aws_vpc.this.ipv6_cidr_block != "" ? data.aws_vpc.this.ipv6_cidr_block : null
  from_port         = var.efs_nfs_mount_port
  to_port           = var.efs_nfs_mount_port

  tags = {
    Name = format("efs-egress-to-vpc-%s", var.efs_nfs_mount_port)
  }
}

resource "aws_vpc_security_group_egress_rule" "asg_egress_nfs_to_efs" {
  count = var.efs_create_file_system ? 1 : 0

  ip_protocol                  = "tcp"
  description                  = "ASG Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id            = var.asg_security_group_id
  referenced_security_group_id = aws_security_group.efs.0.id
  from_port                    = var.efs_nfs_mount_port
  to_port                      = var.efs_nfs_mount_port

  tags = {
    Name = format("asg-egress-to-efs-%s", var.efs_nfs_mount_port)
  }
}

resource "aws_vpc_security_group_egress_rule" "asg_egress_nfs_to_existing_efs" {
  count = var.efs_use_existing_filesystem ? 1 : 0

  ip_protocol                  = "tcp"
  description                  = "ASG Egress on port ${var.efs_nfs_mount_port} for ${var.name_prefix}"
  security_group_id            = var.asg_security_group_id
  referenced_security_group_id = var.efs_security_group_id
  from_port                    = var.efs_nfs_mount_port
  to_port                      = var.efs_nfs_mount_port

  lifecycle {
    precondition {
      condition     = var.efs_security_group_id != null
      error_message = "To use an existing filesystem the input efs_security_group_id must be provided."
    }
  }

  tags = {
    Name = format("asg-egress-to-efs-%s", var.efs_nfs_mount_port)
  }
}
