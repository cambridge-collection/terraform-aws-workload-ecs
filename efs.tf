data "aws_subnet" "efs" {
  count = length(var.vpc_subnet_ids)

  id = var.vpc_subnet_ids[count.index]
}

# NOTE EFS File System must be multi-AZ as we do not know in advance in which AZ the task will be placed
resource "aws_efs_file_system" "this" {
  count = var.use_efs_persistence ? 1 : 0

  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = {
    Name = "${var.name_prefix}-efs"
  }
}

resource "aws_efs_mount_target" "this" {
  count = var.use_efs_persistence ? length(var.vpc_subnet_ids) : 0

  file_system_id = aws_efs_file_system.this.0.id
  subnet_id      = data.aws_subnet.efs[count.index].id
}

# NOTE EFS does not need an access point as only the Docker containers need access, not the host
