resource "aws_codedeploy_app" "this" {
  count = var.use_codedeploy ? 1 : 0

  compute_platform = "ECS"
  name             = var.name_prefix
}

resource "aws_codedeploy_deployment_group" "this" {
  count = var.use_codedeploy ? 1 : 0

  app_name               = aws_codedeploy_app.this.0.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = var.name_prefix
  service_role_arn       = aws_iam_role.codedeploy.0.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.codedeploy_deployment_type == "BLUE_GREEN" ? [1] : []
    content {
      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
      }

      terminate_blue_instances_on_deployment_success {
        action                           = "TERMINATE"
        termination_wait_time_in_minutes = 5
      }
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL" # routes traffic behind a load balancer
    deployment_type   = var.codedeploy_deployment_type
  }

  ecs_service {
    cluster_name = regex("(?:service/)(?P<cluster_name>\\S+)(?:/)", aws_ecs_service.codedeploy.0.id).cluster_name
    service_name = aws_ecs_service.codedeploy.0.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      target_group {
        name = aws_lb_target_group.this.name
      }

      dynamic "target_group" {
        for_each = var.codedeploy_deployment_type == "BLUE_GREEN" ? [1] : []
        content {
          name = aws_lb_target_group.green.0.name
        }
      }
    }
  }
}
