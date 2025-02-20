resource "aws_appautoscaling_target" "this" {
  count = var.ecs_service_use_app_autoscaling ? 1 : 0

  max_capacity       = var.ecs_service_max_capacity
  min_capacity       = var.ecs_service_desired_count
  resource_id        = format("service/%s/%s-service", var.ecs_cluster_name, var.name_prefix)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    precondition {
      condition     = var.ecs_cluster_name != null
      error_message = "Input ecs_cluster_name must be supplied to turn on ECS service auto scaling"
    }
  }
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
