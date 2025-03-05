output "name_prefix" {
  value       = var.name_prefix
  description = "This is a convenience for recycling into the task definition template"
}

output "ecr_repository_urls" {
  value       = local.ecr_repository_urls
  description = "Map of ECR Repsitory name keys and Repository URLs"
}

output "link" {
  value       = var.allow_private_access ? "" : "https://${aws_route53_record.cloudfront_alias.0.name}"
  description = "Link to connect to the service"
}

output "domain_name" {
  value       = var.allow_private_access ? "" : aws_route53_record.cloudfront_alias.0.name
  description = "Name of the DNS record created in Route 53 aliasing the CloudFront Distribution"
}

output "private_access_host" {
  value       = join(".", [var.ecs_service_container_name, var.name_prefix])
  description = "Route 53 record name for the A record created by Cloud Map Service Discovery"
}

output "private_access_port" {
  value       = var.allow_private_access ? tostring(var.alb_target_group_port) : ""
  description = "Port number for accessing service via private access host name"
}

output "alb_target_group_arn" {
  value       = var.allow_private_access ? "" : aws_lb_target_group.this.0.arn
  description = "ARN of the Load Balancer Target Group"
}

output "cloudmap_service_discovery_namespace_name" {
  value       = var.name_prefix
  description = "Name of the Cloud Map Service Discovery Namespace for use by DiscoverInstances API"
}

output "cloudmap_service_discovery_service_name" {
  value       = var.ecs_service_container_name
  description = "Name of the Cloud Map Service Discovery Service for use by DiscoverInstances API"
}

output "ecs_service_id" {
  value       = aws_ecs_service.this.id
  description = "ID of the ECS Service"
}
