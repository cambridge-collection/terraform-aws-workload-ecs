# NOTE EFS File System must be multi-AZ as we do not know in advance in which AZ the task will be placed
resource "aws_efs_file_system" "this" {
  count = var.efs_create_file_system ? 1 : 0

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

  lifecycle {
    precondition {
      condition     = length(var.vpc_subnet_ids) > 0
      error_message = "EFS resources require the vpc_subnet_ids input to be provided."
    }
  }
}

resource "aws_efs_mount_target" "this" {
  count = var.efs_create_file_system ? length(var.vpc_subnet_ids) : 0

  file_system_id  = aws_efs_file_system.this.0.id
  subnet_id       = data.aws_subnet.ecs[count.index].id
  security_groups = [aws_security_group.efs.0.id]

  lifecycle {
    precondition {
      condition     = length(var.vpc_subnet_ids) > 0
      error_message = "EFS resources require the vpc_subnet_ids input to be provided."
    }
  }
}

resource "aws_efs_access_point" "this" {
  count = var.efs_create_file_system ? 1 : 0

  file_system_id = aws_efs_file_system.this.0.id

  posix_user {
    gid            = var.efs_access_point_posix_user_uid
    uid            = var.efs_access_point_posix_user_gid
    secondary_gids = var.efs_access_point_posix_user_secondary_gids
  }

  root_directory {
    path = var.efs_access_point_root_directory_path

    creation_info {
      owner_gid   = var.efs_access_point_posix_user_uid
      owner_uid   = var.efs_access_point_posix_user_gid
      permissions = var.efs_access_point_root_directory_permissions
    }
  }

  tags = {
    Name = "${var.name_prefix}-efs-access-point"
  }

  lifecycle {
    precondition {
      condition     = length(var.vpc_subnet_ids) > 0
      error_message = "EFS resources require the vpc_subnet_ids input to be provided."
    }
  }
}

resource "aws_efs_access_point" "other" {
  count = var.efs_use_existing_filesystem ? 1 : 0

  file_system_id = var.efs_file_system_id

  posix_user {
    gid            = var.efs_access_point_posix_user_uid
    uid            = var.efs_access_point_posix_user_gid
    secondary_gids = var.efs_access_point_posix_user_secondary_gids
  }

  root_directory {
    path = var.efs_access_point_root_directory_path

    creation_info {
      owner_gid   = var.efs_access_point_posix_user_uid
      owner_uid   = var.efs_access_point_posix_user_gid
      permissions = var.efs_access_point_root_directory_permissions
    }
  }

  tags = {
    Name = "${var.name_prefix}-efs-access-point"
  }

  lifecycle {
    precondition {
      condition     = length(var.vpc_subnet_ids) > 0
      error_message = "EFS resources require the vpc_subnet_ids input to be provided."
    }

    precondition {
      condition     = var.efs_file_system_id != null
      error_message = "To use an existing filesystem the input efs_file_system_id must be provided."
    }
  }
}
