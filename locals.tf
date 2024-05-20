locals {
  ecr_repository_urls = var.ecr_repositories_exist ? { for name, repo in data.aws_ecr_repository.existing : name => repo.repository_url } : { for name, repo in aws_ecr_repository.new : name => repo.repository_url }
  ecr_repository_arns = var.ecr_repositories_exist ? [for name, repo in data.aws_ecr_repository.existing : repo.arn] : [for name, repo in aws_ecr_repository.new : repo.arn]
}
