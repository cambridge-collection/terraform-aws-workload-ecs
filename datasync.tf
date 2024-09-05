locals {
  use_datasync = local.ecs_task_definition_mount_efs && var.datasync_s3_objects_to_efs
}

data "aws_s3_bucket" "datasync" {
  count = local.use_datasync ? 1 : 0

  bucket = coalesce(var.datasync_s3_source_bucket_name, var.s3_task_execution_bucket)
}

resource "aws_datasync_location_s3" "source" {
  count = var.datasync_s3_objects_to_efs ? 1 : 0

  s3_bucket_arn = data.aws_s3_bucket.datasync.0.arn
  subdirectory  = var.datasync_s3_subdirectory

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync.0.arn
  }

  depends_on = [aws_efs_mount_target.this]
}

resource "aws_datasync_location_efs" "target" {
  for_each = local.use_datasync ? { for subnet in data.aws_subnet.ecs : subnet.id => subnet } : {}

  efs_file_system_arn = aws_efs_file_system.this.0.arn
  subdirectory        = "/" # NOTE replicated data would normally go in root of file system

  ec2_config {
    subnet_arn          = each.value.arn
    security_group_arns = [aws_security_group.efs.0.arn]
  }

  depends_on = [aws_efs_mount_target.this] # NOTE needs a dependency as the datasync location needs a mount target in each subnet
}

resource "aws_datasync_task" "s3_to_efs" {
  for_each = local.use_datasync ? { for subnet in data.aws_subnet.ecs : subnet.id => subnet } : {}

  name                     = "${var.name_prefix}-s3-to-efs-${each.value.availability_zone}"
  source_location_arn      = aws_datasync_location_s3.source.0.arn
  destination_location_arn = aws_datasync_location_efs.target[each.key].arn

  options {
    bytes_per_second       = var.datasync_bytes_per_second
    preserve_deleted_files = var.datasync_preserve_deleted_files
    overwrite_mode         = var.datasync_overwrite_mode
    transfer_mode          = var.datasync_transfer_mode
  }

  dynamic "includes" {
    for_each = var.datasync_s3_to_efs_pattern != null ? [1] : []

    content {
      filter_type = "SIMPLE_PATTERN"
      value       = var.datasync_s3_to_efs_pattern
    }
  }

  depends_on = [aws_s3_object.task_execution] # NOTE this resource should not be created until S3 objects in source have been created
}
