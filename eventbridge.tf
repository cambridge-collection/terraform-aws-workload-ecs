resource "aws_cloudwatch_event_rule" "ecs_stopped_tasks" {
  count = var.eventbridge_monitor_stopped_tasks ? 1 : 0

  name        = "ecs-stopped-tasks-${var.name_prefix}"
  description = "Triggered when an Amazon ECS Task is stopped for ${var.name_prefix}"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      desiredStatus     = ["STOPPED"]
      lastStatus        = ["STOPPED"]
      taskDefinitionArn = [aws_ecs_task_definition.this.arn]
    }
  })
}

resource "aws_cloudwatch_event_target" "cloud_watch" {
  count = var.eventbridge_monitor_stopped_tasks ? 1 : 0

  rule      = aws_cloudwatch_event_rule.ecs_stopped_tasks.0.name
  target_id = "ecs-stopped-tasks-${var.name_prefix}"
  arn       = aws_cloudwatch_log_group.ecs_stopped_tasks.0.arn
}

resource "aws_cloudwatch_log_group" "ecs_stopped_tasks" {
  count = var.eventbridge_monitor_stopped_tasks ? 1 : 0

  name = "/aws/events/ecs/stopped-tasks/${var.name_prefix}"
}

resource "aws_cloudwatch_log_resource_policy" "ecs_stopped_tasks" {
  count = var.eventbridge_monitor_stopped_tasks ? 1 : 0

  policy_document = data.aws_iam_policy_document.create_log_events.json
  policy_name     = "ecs-stopped-tasks-policy"
}

data "aws_iam_policy_document" "create_log_events" {
  statement {
    sid    = "LogEventsCreateLogStream"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
    actions = [
      "logs:CreateLogStream",
    ]
    resources = ["${aws_cloudwatch_log_group.ecs_stopped_tasks.0.arn}:*"]
  }

  statement {
    sid    = "LogEventsPutLogEvents"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
    actions = [
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.ecs_stopped_tasks.0.arn}:*:*"]
    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.ecs_stopped_tasks.0.arn]
      variable = "aws:SourceArn"
    }
  }
}
