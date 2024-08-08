resource "aws_cloudwatch_event_rule" "ecs_stopped_tasks" {
  name        = "ECSStoppedTasksEvent"
  description = "Triggered when an Amazon ECS Task is stopped"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      desiredStatus = ["STOPPED"]
      lastStatus    = ["STOPPED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "cloud_watch" {
  rule      = aws_cloudwatch_event_rule.ecs_stopped_tasks.name
  target_id = "ECSStoppedTasks"
  arn       = aws_cloudwatch_log_group.ecs_stopped_tasks.arn
}

resource "aws_cloudwatch_log_group" "ecs_stopped_tasks" {
  name = "/ecs/ECSStoppedTasksEvent"
}

resource "aws_cloudwatch_log_resource_policy" "ecs_stopped_tasks" {
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
    resources = ["${aws_cloudwatch_log_group.ecs_stopped_tasks.arn}:*"]
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
    resources = ["${aws_cloudwatch_log_group.ecs_stopped_tasks.arn}:*:*"]
    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.ecs_stopped_tasks.arn]
      variable = "aws:SourceArn"
    }
  }
}
