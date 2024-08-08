resource "aws_cloudwatch_event_rule" "ecs_stopped_tasks" {
  name        = "ECSStoppedTasksEvent"
  description = "Triggered when an Amazon ECS Task is stopped"

  event_pattern = jsonencode({
    source = ["aws.ecs"]
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
  arn       = var.cloudwatch_log_group_arn
}
