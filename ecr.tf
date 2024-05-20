resource "aws_ecr_repository" "new" {
  for_each = var.ecr_repositories_exist ? toset([]) : toset(var.ecr_repository_names)

  name         = "${var.name_prefix}-${each.value}"
  force_delete = var.ecr_repository_force_delete
}

data "aws_ecr_repository" "existing" {
  for_each = var.ecr_repositories_exist ? toset(var.ecr_repository_names) : toset([])

  name = each.key
}
