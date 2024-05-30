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

  file_system_id  = aws_efs_file_system.this.0.id
  subnet_id       = data.aws_subnet.efs[count.index].id
  security_groups = [aws_security_group.efs.0.id]
}

resource "aws_efs_access_point" "this" {
  count = var.use_efs_persistence && var.efs_use_access_point ? 1 : 0

  file_system_id = aws_efs_file_system.this.0.id

  posix_user {
    gid            = var.efs_posix_user_gid
    uid            = var.efs_posix_user_uid
    secondary_gids = var.efs_posix_user_secondary_gids
  }

  root_directory {
    path = var.efs_root_directory_path

    creation_info {
      owner_gid   = var.efs_posix_user_gid
      owner_uid   = var.efs_posix_user_uid
      permissions = var.efs_root_directory_permissions
    }
  }

  tags = {
    Name = "${var.name_prefix}-efs-access-point"
  }
}
