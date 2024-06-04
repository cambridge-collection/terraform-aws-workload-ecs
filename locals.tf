locals {
  ecr_repository_urls                      = var.ecr_repositories_exist ? { for name, repo in data.aws_ecr_repository.existing : name => repo.repository_url } : { for name, repo in aws_ecr_repository.new : name => repo.repository_url }
  ecr_repository_arns                      = var.ecr_repositories_exist ? [for name, repo in data.aws_ecr_repository.existing : repo.arn] : [for name, repo in aws_ecr_repository.new : repo.arn]
  s3_task_execution_bucket_arn             = var.s3_task_execution_bucket != null ? format("arn:aws:s3:::%s", var.s3_task_execution_bucket) : null
  s3_task_execution_additional_bucket_arns = [for bucket in var.s3_task_execution_additional_buckets : format("arn:aws:s3:::%s", bucket)]
  s3_task_execution_bucket_arns            = flatten(compact([local.s3_task_execution_bucket_arn]), local.s3_task_execution_additional_bucket_arns)
  s3_task_execution_bucket_arns_iam        = distinct(flatten(local.s3_task_execution_bucket_arns, [for bucket in local.s3_task_execution_bucket_arns : format("%s/*", bucket)]))
  s3_task_role_bucket_arn                  = var.s3_task_bucket != null ? format("arn:aws:s3:::%s", var.s3_task_bucket) : null
  s3_task_role_bucket_arns_iam             = local.s3_task_role_bucket_arn != null ? [local.s3_task_role_bucket_arn, format("%s/*", local.s3_task_role_bucket_arn)] : []
}
