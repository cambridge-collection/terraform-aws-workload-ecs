locals {
  ecr_repository_urls                      = var.ecr_repositories_exist ? { for name, repo in data.aws_ecr_repository.existing : name => repo.repository_url } : { for name, repo in aws_ecr_repository.new : name => repo.repository_url }
  ecr_repository_arns                      = var.ecr_repositories_exist ? [for name, repo in data.aws_ecr_repository.existing : repo.arn] : [for name, repo in aws_ecr_repository.new : repo.arn]
  ecs_service_resource_id                  = split(format(":%s:", var.account_id), aws_ecs_service.this.id)[1]
  s3_task_execution_bucket_arn             = var.s3_task_execution_bucket != null ? format("arn:aws:s3:::%s", var.s3_task_execution_bucket) : null
  s3_task_execution_additional_bucket_arns = [for bucket in var.s3_task_execution_additional_buckets : format("arn:aws:s3:::%s", bucket)]
  s3_task_execution_bucket_arns            = concat(compact([local.s3_task_execution_bucket_arn]), local.s3_task_execution_additional_bucket_arns)
  s3_task_execution_bucket_arns_iam        = distinct(concat(local.s3_task_execution_bucket_arns, [for bucket in local.s3_task_execution_bucket_arns : format("%s/*", bucket)]))
  s3_task_role_bucket_arns                 = [for bucket in var.s3_task_buckets : format("arn:aws:s3:::%s", bucket)]
  s3_task_role_bucket_arns_iam             = concat(local.s3_task_role_bucket_arns, [for arn in local.s3_task_role_bucket_arns : format("%s/*", arn)])
}
