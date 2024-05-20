locals {
  iam_role_prefix = "${var.name_prefix}-workload"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  path                 = "/"
  description          = "Executes ECS Tasks for ${local.iam_role_prefix}"
  name                 = trimprefix(substr("${local.iam_role_prefix}-execution-role", -64, -1), "-")
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role.json
  max_session_duration = 3600
  tags                 = {}
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "${local.iam_role_prefix}-execution-policy"
  path        = "/"
  description = "Policy for ${local.iam_role_prefix}-execution-role"
  policy      = data.aws_iam_policy_document.task_execution_role_permissions.json
}

data "aws_iam_policy_document" "task_execution_role_permissions" {
  statement {
    actions   = ["ecr:*"]
    resources = local.ecr_repository_arns
  }
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${var.cloudwatch_log_group_arn}:log-stream:*"]
  }
  dynamic "statement" {
    for_each = length(var.s3_task_execution_role_bucket_arns) > 0 ? [1] : []
    content {
      actions   = ["s3:*"]
      resources = var.s3_task_execution_role_bucket_arns
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_iam_role" "task_role" {
  path                 = "/"
  description          = "Assumed by containers in ${local.iam_role_prefix}"
  name                 = trimprefix(substr("${local.iam_role_prefix}-task-role", -64, -1), "-")
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role.json
  max_session_duration = 3600
  tags                 = {}
}

resource "aws_iam_policy" "task_policy" {
  name        = "${local.iam_role_prefix}-task-policy"
  path        = "/"
  description = "Policy for ${local.iam_role_prefix}-task-role"
  policy      = data.aws_iam_policy_document.task_role_permissions.json
}

data "aws_iam_policy_document" "task_role_permissions" {
  dynamic "statement" {
    for_each = length(var.s3_task_role_bucket_arns) > 0 ? [1] : []
    content {
      actions   = ["s3:Get*", "s3:List*"]
      resources = var.s3_task_role_bucket_arns
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}
