variable "tags" {
  type        = map(string)
  description = "Map of tags for adding to resources"
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "Prefix to add to resource names"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID used to interpolate ECS Service IAM role ARN"
}

variable "domain_name" {
  type        = string
  description = "Domain Name to be used for the ACM certificate and Route 53 record"
}

variable "allow_private_access" {
  type        = bool
  description = "Whether to allow private access to the service"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC for the deployment"
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB used by the listener"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name for the ALB used by the Cloudfront distribution"
}

variable "cloudfront_waf_acl_arn" {
  type        = string
  description = "ARN of the WAF Web ACL for use by CloudFront"
}

variable "cloudfront_allowed_methods" {
  type        = list(string)
  description = "List of methods allowed by the CloudFront Distribution"
  default     = ["HEAD", "GET", "OPTIONS"]
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  description = "List of methods cached by the CloudFront Distribution"
  default     = ["HEAD", "GET"]
}

variable "ecr_repository_force_delete" {
  type        = bool
  description = "Whether to delete non-empty ECR repositories"
  default     = false
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster for use by aws_appautoscaling_target resource"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster to which this workload should be deployed"
}

variable "ecs_service_desired_count" {
  type        = number
  description = "Sets the Desired Count for the ECS Service"
  default     = 1
}

variable "ecs_service_max_capacity" {
  type        = number
  description = "Sets the Maximum Capacity for the ECS Service"
  default     = 2
}

variable "ecs_service_min_capacity" {
  type        = number
  description = "Sets the Minimum Capacity for the ECS Service"
  default     = 1
}

variable "ecs_service_container_name" {
  type        = string
  description = "Name of container to associated with the load balancer configuration in the ECS service"
}

variable "ecs_service_container_port" {
  type        = number
  description = "Container port number associated load balancer configuration in the ECS service. This must match a container port in the container definition port mappings"
}

variable "ecs_service_iam_role" {
  type        = string
  description = "ARN of an IAM role to call load balancer for non-awsvpc network modes. AWSServiceRoleForECS is suitable, but AWS will generate an error if the value is used and the role already exists in the account"
  default     = null
}

variable "ecs_task_def_container_definitions" {
  type        = string
  description = "Container Definition string for ECS Task Definition. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html"
  sensitive   = true
}

variable "ecs_task_def_cpu" {
  type        = number
  description = "Number of cpu units used by the task"
  default     = null
}

variable "ecs_task_def_memory" {
  type        = number
  description = "Amount (in MiB) of memory used by the task. Note if this is unset, all container definitions must set memory and/or memoryReservation"
  default     = 1024
}

variable "ecs_task_def_volumes" {
  type        = list(string)
  description = "List of volume names to attach to the ECS Task Definition"
  default     = []
}

variable "ecs_network_mode" {
  type        = string
  description = "Networking mode specified in the ECS Task Definition. One of host, bridge, awsvpc"
  default     = "bridge"
}

variable "ecr_repository_names" {
  type        = list(string)
  description = "List of names of ECR repositories required by this workload"
  default     = []
}

variable "ecr_repositories_exist" {
  type        = bool
  description = "Whether the ECR repositories in ecr_repository_names already exist"
  default     = false
}

variable "alb_listener_arn" {
  type        = string
  description = "The Application Load Balancer Listener ARN to add the forward rule and certificate to"
}

variable "alb_listener_rule_priority" {
  type        = string
  description = <<-DESCRIPTION
  The priority for the rule between 1 and 50000.
  Leaving it unset will automatically set the rule with next available priority
  after currently existing highest rule. A listener can't have multiple rules
  with the same priority.
  DESCRIPTION
  default     = null
}

variable "s3_env_bucket" {
  type        = string
  description = "Name of the bucket where the environment file should be located"
}

variable "s3_env_objects" {
  type        = map(string)
  description = "Map of S3 bucket keys (file names) and file contents for upload"
  default     = {}
  sensitive   = true
}

variable "s3_data_source_bucket" {
  type        = string
  description = "Name of the date source S3 Bucket"
}

variable "s3_data_source_objects" {
  type        = map(string)
  description = "Map of S3 bucket keys (file names) and file contents for upload"
  default     = {}
  sensitive   = true
}

variable "s3_task_execution_role_bucket_arns" {
  type        = list(string)
  description = "List of S3 Bucket ARNs for adding to IAM task execution role policy"
}

variable "s3_task_role_bucket_arns" {
  type        = list(string)
  description = "List of S3 Bucket ARNs for adding to IAM task role policy"
}

variable "cloudwatch_log_group_arn" {
  type        = string
  description = "ARN of the CloudWatch Log Group for adding to IAM task execution role policy"
}

variable "alb_target_group_port" {
  type        = number
  description = "Port number to use for the target group"
}

variable "alb_target_group_protocol" {
  type        = string
  description = "Protocol to use for the target group"
  default     = "HTTP"
}

variable "alb_target_group_health_check_status_code" {
  type        = string
  description = "HTTP Status Code to use in target group health check"
  default     = "200"
}

variable "alb_target_group_health_check_interval" {
  type        = number
  description = "Time in seconds between health checks"
  default     = 60
}

variable "alb_target_group_health_check_path" {
  type        = string
  description = "Path for health checks on the service"
  default     = "/"
}

variable "alb_target_group_health_check_timeout" {
  type        = number
  description = "Time in seconds after which no response from a target means a failed health check"
  default     = 10
}

variable "alb_target_group_health_check_unhealthy_threshold" {
  type        = number
  description = "The number of checks before a target is registered as Unhealthy"
  default     = 5
}

variable "alb_target_group_health_check_healthy_threshold" {
  type        = number
  description = "The number of checks before a target is registered as Healthy"
  default     = 2
}

variable "route53_zone_id" {
  type        = string
  description = "ID of the Route 53 Hosted Zone for records"
}

variable "asg_name" {
  type        = string
  description = "Name of Autoscaling Group for registering with ALB Target Group"
}

variable "asg_security_group_id" {
  type        = string
  description = "ID of the ASG Security Group for creating ingress from from ALB"
}

variable "alb_security_group_id" {
  type        = string
  description = "ID of the ALB Security Group for creating ingress from from ALB"
}

variable "acm_certificate_validation_timeout" {
  type        = string
  description = "Length of time to wait for the public ACM certificate to validate"
  default     = "10m"
}
