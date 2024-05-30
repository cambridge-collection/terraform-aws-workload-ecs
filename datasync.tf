locals {
  use_datasync = var.use_efs_persistence && var.datasync_s3_service_objects_to_efs
}

resource "aws_datasync_location_efs" "this" {
  count = local.use_datasync ? length(data.aws_subnet.efs.*.arn) : 0

  efs_file_system_arn = aws_efs_file_system.this.0.arn
  subdirectory        = "/" # NOTE replicated data would normally go in root of file system

  ec2_config {
    subnet_arn          = data.aws_subnet.efs[count.index].arn
    security_group_arns = [aws_security_group.efs.0.arn]
  }
}

resource "aws_datasync_location_s3" "this" {
  count = local.use_datasync ? 1 : 0

  s3_bucket_arn = var.s3_service_bucket_arn
  subdirectory  = var.name_prefix

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync.0.arn
  }
}

resource "aws_datasync_task" "s3_to_efs" {
  count = local.use_datasync ? length(data.aws_subnet.efs.*.arn) : 0

  name                     = "${var.name_prefix}-s3-to-efs"
  source_location_arn      = aws_datasync_location_s3.this.0.arn
  destination_location_arn = aws_datasync_location_efs.this[count.index].arn

  options {
    bytes_per_second       = -1
    preserve_deleted_files = "REMOVE"
    overwrite_mode         = "ALWAYS"
  }
}
