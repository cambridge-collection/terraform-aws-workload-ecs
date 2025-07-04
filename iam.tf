locals {
  iam_role_prefix = "${var.name_prefix}-workload"
}

data "aws_region" "this" {}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

data "aws_efs_file_system" "other" {
  count = var.efs_use_existing_filesystem ? 1 : 0

  file_system_id = var.efs_file_system_id
}

resource "aws_iam_role" "task_execution_role" {
  path                 = "/"
  description          = "Executes ECS Tasks for ${local.iam_role_prefix}"
  name                 = trimprefix(substr("${local.iam_role_prefix}-execution-role", -64, -1), "-")
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role.json
  max_session_duration = 3600
  tags = {
    Name = trimprefix(substr("${local.iam_role_prefix}-execution-role", -64, -1), "-")
  }
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "${local.iam_role_prefix}-execution-policy"
  path        = "/"
  description = "Policy for ${local.iam_role_prefix}-execution-role"
  policy      = data.aws_iam_policy_document.task_execution_role_permissions.json
  tags = {
    Name = "${local.iam_role_prefix}-execution-policy"
  }
}

data "aws_iam_policy_document" "task_execution_role_permissions" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${var.cloudwatch_log_group_arn}:log-stream:*"]
  }

  dynamic "statement" {
    for_each = length(local.ecr_repository_arns) > 0 ? [1] : []
    content {
      actions   = ["ecr:*"]
      resources = local.ecr_repository_arns
    }
  }

  dynamic "statement" {
    for_each = length(local.s3_task_execution_bucket_arns_iam) > 0 ? [1] : []
    content {
      actions   = ["s3:*"]
      resources = local.s3_task_execution_bucket_arns_iam
    }
  }

  dynamic "statement" {
    for_each = length(var.ssm_task_execution_parameter_arns) > 0 ? [1] : []
    content {
      actions = [
        "ssm:DescribeParameters",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:GetParameterHistory"
      ]
      resources = var.ssm_task_execution_parameter_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.secrets_manager_task_execution_secret_arns) > 0 ? [1] : []
    content {
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = var.secrets_manager_task_execution_secret_arns
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
  tags = {
    Name = trimprefix(substr("${local.iam_role_prefix}-task-role", -64, -1), "-")
  }
}

resource "aws_iam_policy" "task_policy" {
  count       = data.aws_iam_policy_document.task_role_permissions.statement != null ? 1 : 0
  name        = "${local.iam_role_prefix}-task-policy"
  path        = "/"
  description = "Policy for ${local.iam_role_prefix}-task-role"
  policy      = data.aws_iam_policy_document.task_role_permissions.json
  tags = {
    Name = "${local.iam_role_prefix}-task-policy"
  }
}

data "aws_iam_policy_document" "task_role_permissions" {
  dynamic "statement" {
    for_each = length(local.s3_task_role_bucket_arns_iam) > 0 ? [1] : []
    content {
      actions   = ["s3:Get*", "s3:List*"]
      resources = local.s3_task_role_bucket_arns_iam
    }
  }
  # NOTE see https://docs.aws.amazon.com/efs/latest/ug/security_iam_resource-based-policy-examples.html
  dynamic "statement" {
    for_each = local.ecs_task_definition_mount_efs ? [1] : []
    content {
      actions = [
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount"
      ]
      resources = [try(aws_efs_file_system.this.0.arn, data.aws_efs_file_system.other.0.arn)]
      condition {
        test     = "Bool"
        variable = "elasticfilesystem:AccessedViaMountTarget"
        values   = ["true"]
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  count = data.aws_iam_policy_document.task_role_permissions.statement != null ? 1 : 0

  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.0.arn
}

data "aws_iam_policy_document" "datasync_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:datasync:${data.aws_region.this.name}:${var.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "datasync_permissions" {
  count = var.datasync_s3_objects_to_efs ? 1 : 0

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [data.aws_s3_bucket.datasync.0.arn]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["${data.aws_s3_bucket.datasync.0.arn}/*"]
  }
}

resource "aws_iam_policy" "datasync" {
  count = var.datasync_s3_objects_to_efs ? 1 : 0

  name        = trimprefix(substr("${local.iam_role_prefix}-datasync", -64, -1), "-")
  path        = "/"
  description = "Policy for ${local.iam_role_prefix}-datasync"
  policy      = data.aws_iam_policy_document.datasync_permissions.0.json
  tags = {
    Name = trimprefix(substr("${local.iam_role_prefix}-datasync", -64, -1), "-")
  }
}

resource "aws_iam_role" "datasync" {
  count = var.datasync_s3_objects_to_efs ? 1 : 0

  path                 = "/"
  description          = "Assumed by DataSync for ${local.iam_role_prefix}"
  name                 = trimprefix(substr("${local.iam_role_prefix}-datasync", -64, -1), "-")
  assume_role_policy   = data.aws_iam_policy_document.datasync_assume_role.json
  max_session_duration = 3600
  tags = {
    Name = trimprefix(substr("${local.iam_role_prefix}-datasync", -64, -1), "-")
  }
}

resource "aws_iam_role_policy_attachment" "datasync" {
  count = var.datasync_s3_objects_to_efs ? 1 : 0

  role       = aws_iam_role.datasync.0.name
  policy_arn = aws_iam_policy.datasync.0.arn
}

resource "aws_iam_role_policy_attachment" "task_additional_policy_attachment" {
  for_each = var.iam_task_additional_policies

  role       = aws_iam_role.task_role.name
  policy_arn = each.value
}
