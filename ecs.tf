resource "aws_ecs_task_definition" "this" {
  container_definitions = var.ecs_task_def_container_definitions
  family                = var.name_prefix
  task_role_arn         = aws_iam_role.task_role.arn
  execution_role_arn    = aws_iam_role.task_execution_role.arn
  network_mode          = var.ecs_network_mode
  cpu                   = var.ecs_task_def_cpu
  memory                = var.ecs_task_def_memory

  requires_compatibilities = [
    "EC2"
  ]

  dynamic "volume" {
    for_each = toset(var.ecs_task_def_volumes)
    content {
      name = join("-", [var.name_prefix, volume.key])

      dynamic "efs_volume_configuration" {
        for_each = var.use_efs_persistence ? [1] : []

        content {
          file_system_id     = aws_efs_file_system.this.0.id
          transit_encryption = "ENABLED"

          authorization_config {
            access_point_id = aws_efs_access_point.this.0.id
            iam             = "ENABLED"
          }
        }
      }
    }
  }

  tags = {
    Name = "${var.name_prefix}-ecs-task-def"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_ecr_repository.new]
}

resource "aws_ecs_service" "this" {
  name                               = "${var.name_prefix}-service"
  cluster                            = var.ecs_cluster_arn
  desired_count                      = var.ecs_service_desired_count
  task_definition                    = aws_ecs_task_definition.this.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  iam_role                           = var.ecs_network_mode == "awsvpc" ? null : var.ecs_service_iam_role
  scheduling_strategy                = "REPLICA"
  propagate_tags                     = "SERVICE"

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.ecs_service_container_name
    container_port   = var.ecs_service_container_port
  }

  dynamic "service_registries" {
    for_each = var.allow_private_access ? [1] : []
    content {
      registry_arn   = aws_service_discovery_service.this.0.arn
      container_name = var.ecs_service_container_name
      container_port = var.ecs_service_container_port
    }
  }
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_service_max_capacity
  min_capacity       = var.ecs_service_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}