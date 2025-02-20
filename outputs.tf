# NOTE there seems to be no way of listing Route53 records natively in the aws provider
data "external" "route53_a_record" {
  count = var.allow_private_access ? 1 : 0
  program = ["bash", "-c", <<-SHELL
  input=$(cat)
  aws route53 list-resource-record-sets --cli-input-json $input --query 'ResourceRecordSets[?Type==`A`].{name: Name, value: ResourceRecords[0].Value} | [0]'
  SHELL
  ]

  query = {
    HostedZoneId = aws_service_discovery_private_dns_namespace.this.0.hosted_zone
  }

  depends_on = [aws_service_discovery_private_dns_namespace.this.0, aws_service_discovery_service.this.0]
}

output "name_prefix" {
  value       = var.name_prefix
  description = "This is a convenience for recycling into the task definition template"
}

output "ecr_repository_urls" {
  value       = local.ecr_repository_urls
  description = "Map of ECR Repsitory name keys and Repository URLs"
}

output "link" {
  value       = "https://${aws_route53_record.cloudfront_alias.name}"
  description = "Link to connect to the service"
}

output "domain_name" {
  value       = aws_route53_record.cloudfront_alias.name
  description = "Name of the DNS record created in Route 53 aliasing the CloudFront Distribution"
}

output "private_access_host" {
  value       = try(data.external.route53_a_record.0.result.name, "UNDEFINED")
  description = "Route 53 record name for the A record created by Cloud Map Service Discovery"
}

output "private_access_port" {
  value       = var.allow_private_access ? tostring(var.alb_target_group_port) : ""
  description = "Port number for accessing service via private access host name"
}

output "alb_target_group_arn" {
  value       = aws_lb_target_group.this.arn
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
