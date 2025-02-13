resource "aws_appautoscaling_target" "this" {
  count = var.ecs_service_use_app_autoscaling ? 1 : 0

  max_capacity       = 3
  min_capacity       = 1
  resource_id        = local.ecs_service_resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  count = var.ecs_service_use_app_autoscaling ? 1 : 0

  name               = format("%s-service-scaling-policy", var.name_prefix)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.0.resource_id
  scalable_dimension = aws_appautoscaling_target.this.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.0.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
