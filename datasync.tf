locals {
  use_datasync    = var.use_efs_persistence && var.datasync_s3_service_objects_to_efs
  s3_subdirectory = format("/%s/", length(var.datasync_s3_subdirectory) > 0 ? var.datasync_s3_subdirectory : var.name_prefix)
}

resource "aws_datasync_location_s3" "source" {
  count = local.use_datasync ? 1 : 0

  s3_bucket_arn = local.s3_task_execution_bucket_arn
  subdirectory  = local.s3_subdirectory

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync.0.arn
  }
}

resource "aws_datasync_location_efs" "target" {
  count = local.use_datasync ? length(data.aws_subnet.efs.*.arn) : 0

  efs_file_system_arn = aws_efs_file_system.this.0.arn
  subdirectory        = "/" # NOTE replicated data would normally go in root of file system

  ec2_config {
    subnet_arn          = data.aws_subnet.efs[count.index].arn
    security_group_arns = [aws_security_group.efs.0.arn]
  }
}

resource "aws_datasync_task" "s3_to_efs" {
  count = local.use_datasync ? length(data.aws_subnet.efs.*.arn) : 0

  name                     = "${var.name_prefix}-s3-to-efs"
  source_location_arn      = aws_datasync_location_s3.source.0.arn
  destination_location_arn = aws_datasync_location_efs.target[count.index].arn

  options {
    bytes_per_second       = var.datasync_bytes_per_second
    preserve_deleted_files = var.datasync_preserve_deleted_files
    overwrite_mode         = var.datasync_overwrite_mode
    transfer_mode          = var.datasync_transfer_mode
  }

  depends_on = [aws_s3_object.service_object] # NOTE this resource should not be created until S3 objects in source have been created
}
