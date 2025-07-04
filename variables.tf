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

variable "allow_public_access" {
  type        = bool
  description = "Whether to allow public access to the service through the load balancer"
  default     = true
}

variable "efs_create_file_system" {
  type        = bool
  description = "Whether to create an EFS File System to persist data"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC for the deployment"
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "VPC Subnet IDs to use with EFS Mount Points"
  default     = []
}

variable "vpc_security_groups_extra" {
  type        = list(string)
  description = "Additional VPC Security Groups to add to the service"
  default     = []
}

variable "cloudmap_associate_vpc_ids" {
  type        = list(string)
  description = "List of VPC IDs to associate with Cloud Map Service Discovery"
  default     = []
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB used by the listener"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name for the ALB used by the Cloudfront distribution"
}

variable "alternative_domain_names" {
  type        = list(string)
  description = "List of additional domain names to add to ALB listener rule and CloudFront distribution"
  default     = []
}

variable "cloudfront_distribution_create" {
  type        = bool
  description = "Whether to create a CloudFront distribution in front of the service"
  default     = true
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

variable "cloudfront_viewer_request_function_arn" {
  type        = string
  description = "ARN of a CloudFront Function to add to CloudFront Distribution in Request"
  default     = null
}

variable "cloudfront_viewer_response_function_arn" {
  type        = string
  description = "ARN of a CloudFront Function to add to CloudFront Distribution in Response"
  default     = null
}

variable "cloudfront_origin_read_timeout" {
  type        = number
  description = "Read timeout for CloudFront origin"
  default     = 60
}

variable "cloudfront_origin_connection_attempts" {
  type        = number
  description = "Number of times that CloudFront attempts to connect to the origin. Must be between 1-3"
  default     = 3
}

variable "cloudfront_access_logging" {
  type        = bool
  description = "Whether to log CloudFront requests"
  default     = false
}

variable "cloudfront_access_logging_bucket" {
  type        = string
  description = "S3 bucket name for CloudFront access logs"
  default     = null
}

variable "cloudfront_custom_error_responses" {
  type = list(object({
    error_code            = number
    response_page_path    = string
    response_code         = number
    error_caching_min_ttl = number
  }))
  description = "Optional list of custom error pages for the CloudFront Distribution"
  default     = []
}

variable "cloudfront_ordered_cache_behaviors" {
  type = list(object({
    path_pattern           = string
    target_origin_id       = string
    allowed_methods        = optional(list(string), ["GET", "HEAD"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy = optional(string, "redirect-to-https")
    cache_policy_id        = optional(string)
    compress               = optional(bool, true)
  }))
  description = "Optional list of ordered cache behaviours to add to the CloudFront Distribution. Target origin ID must match the id of an origin"
  default     = []
}

variable "cloudfront_additional_origins" {
  type = list(object({
    domain_name       = string
    id                = string
    access_control_id = string
    path              = string
  }))
  description = "Optional list of additional origins to add to the CloudFront Distribution"
  default     = []
}

variable "ecr_repository_force_delete" {
  type        = bool
  description = "Whether to delete non-empty ECR repositories"
  default     = false
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster to which this workload should be deployed"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster to use with Service auto scaling"
  default     = null
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

variable "ecs_service_deployment_maximum_percent" {
  type        = number
  description = "Maximum percentage of tasks to allowed to run during a deployment (percentage of desired count)"
  default     = 200
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  type        = number
  description = "Minimum percentage of tasks to keep running during a deployment (percentage of desired count)"
  default     = 100
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

variable "ecs_service_scheduling_strategy" {
  type        = string
  description = "ECS Service scheduling strategy, either REPLICA or DAEMON"
  default     = "REPLICA"
}

variable "ecs_service_capacity_provider_name" {
  type        = string
  description = "Name of a ECS Capacity Provider to use with the ECS Service, other than the default"
  default     = null
}

variable "ecs_service_capacity_provider_strategy_base" {
  type        = number
  description = "Minimum number of tasks to run on the specified ECS Capacity Provider"
  default     = 1
}

variable "ecs_service_capacity_provider_strategy_weight" {
  type        = number
  description = "Percentage of tasks to run on the specified ECS Capacity Provider"
  default     = 100
}

variable "ecs_service_use_autoscaling" {
  type        = bool
  description = "Whether to add a scaling policy to the ECS service"
  default     = false
}

variable "ecs_service_autoscaling_predefined_metric_type" {
  type        = string
  description = "Predefined metric to use with ECS service app autoscaling policy"
  default     = "ECSServiceAverageCPUUtilization"
}

variable "ecs_service_autoscaling_target_value" {
  type        = number
  description = "Percentage value for the ECS service app autoscaling predefined metric"
  default     = 70
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

variable "ecs_task_def_volumes_efs" {
  type        = list(string)
  description = "List of volume names to attach to the ECS Task Definition to connect to EFS"
  default     = []
}

variable "ecs_task_def_volumes_host" {
  type        = map(string)
  description = "Map of volume name keys and host path values to attach to the ECS Task Definition"
  default     = {}
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

variable "alb_listener_certificate_create" {
  type        = string
  description = "Whether to create a load balancer listener certificate"
  default     = true
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

variable "alb_listener_rule_create" {
  type        = bool
  description = "Whether to create a Load Balancer Listener Rule"
  default     = true
}

variable "alb_listener_rule_path_patterns" {
  type        = list(string)
  description = "Optional list of path patterns to add to the load balancer listener rule"
  default     = []
}

variable "s3_task_execution_bucket" {
  type        = string
  description = "Name of the bucket for storage of static data for services"
  default     = null
}

variable "s3_task_execution_additional_buckets" {
  type        = list(string)
  description = "Names of additional buckets for adding to the task execution IAM role permissions"
  default     = []
}

variable "s3_task_execution_bucket_objects" {
  type        = map(string)
  description = "Map of S3 bucket keys (file names) and file contents for upload to the task execution bucket"
  default     = {}
  sensitive   = true
}

variable "s3_task_buckets" {
  type        = list(string)
  description = "Names of the S3 Buckets for use by ECS tasks on the host (i.e. running containers)"
  default     = []
}

variable "s3_task_bucket_objects" {
  type        = map(string)
  description = "Map of S3 bucket keys (file names) and file contents for upload to the task bucket"
  default     = {}
  sensitive   = true
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

variable "alb_target_group_deregistration_delay" {
  type        = number
  description = "Amount time for ELB to wait before changing the state of a deregistering target from draining to unused"
  default     = 300
}

variable "alb_target_group_slow_start" {
  type        = number
  description = "Amount time for targets to warm up before the load balancer sends them a full share of requests"
  default     = 0
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

variable "route53_create_cloudfront_alias_record" {
  type        = bool
  description = "Whether to create an alias record in the Route 53 hosted zone for the CloudFront distribution"
  default     = true
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
  description = "ID of the ALB Security Group for creating ingress to the ALB"
}

variable "ingress_security_group_id" {
  type        = string
  description = "ID of a security group to grant acess to container instances"
  default     = null
}

variable "update_asg_security_group_to_access_service" {
  type        = bool
  description = "Whether to update the ASG security group by creating an egress rule for this service"
  default     = false
}

variable "acm_create_certificate" {
  type        = bool
  description = "Whether to create a certificate in Amazon Certificate Manager"
  default     = true
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of an existing certificate in Amazon Certificate Manager"
  default     = null
}

variable "acm_certificate_arn_us-east-1" {
  type        = string
  description = "ARN of an existing certificate in us-east-1 AWS Region of Amazon Certificate Manager. For use by CloudFront Distribution"
  default     = null
}

variable "acm_certificate_validation_timeout" {
  type        = string
  description = "Length of time to wait for the public ACM certificate to validate"
  default     = "10m"
}

variable "efs_file_system_id" {
  type        = string
  description = "ID of an existing EFS File System"
  default     = null
}

variable "efs_security_group_id" {
  type        = string
  description = "ID of an existing EFS Security Group to allow access to ASG"
  default     = null
}

variable "efs_use_existing_filesystem" {
  type        = bool
  description = "Whether to use an existing EFS file system"
  default     = false
}

variable "efs_file_system_throughput_mode" {
  type        = string
  description = "Throughput mode for the file system. Valid values: bursting, provisioned, or elastic"
  default     = "bursting"
}

variable "efs_file_system_provisioned_throughput" {
  type        = number
  description = "The throughput, measured in MiB/s, that you want to provision for the file system"
  default     = null
}

variable "efs_access_point_id" {
  type        = string
  description = "ID of an existing EFS Access Point"
  default     = null
}

variable "efs_access_point_root_directory_path" {
  type        = string
  description = "Root directory for EFS access point"
  default     = "/"
}

variable "efs_use_iam_task_role" {
  type        = bool
  description = "Whether to use Amazon ECS task IAM role when mounting EFS"
  default     = true
}

variable "efs_access_point_root_directory_permissions" {
  type        = number
  description = "POSIX permissions to apply to the EFS root directory, in the format of an octal number representing the mode bits"
  default     = 777
}

variable "efs_access_point_posix_user_gid" {
  type        = number
  description = "POSIX group ID used for all file system operations using the EFS access point. Default maps to root user on Amazon Linux"
  default     = 0
}

variable "efs_access_point_posix_user_uid" {
  type        = number
  description = "POSIX user ID used for all file system operations using the EFS access point. Default maps to root user on Amazon Linux"
  default     = 0
}

variable "efs_access_point_posix_user_secondary_gids" {
  type        = list(number)
  description = "Secondary POSIX group IDs used for all file system operations using the EFS access point"
  default     = []
}

variable "efs_nfs_mount_port" {
  type        = number
  description = "NFS protocol port for EFS mounts"
  default     = 2049
}

variable "datasync_s3_objects_to_efs" {
  type        = bool
  description = "Whether to use DataSync to replicate S3 objects to EFS file system"
  default     = false
}

variable "datasync_s3_subdirectory" {
  type        = string
  description = "Allows a custom S3 subdirectory for DataSync source to be specified"
  default     = "/"
}

variable "datasync_s3_source_bucket_name" {
  type        = string
  description = "Name of an S3 bucket to use as DataSync source"
  default     = null
}

variable "datasync_bytes_per_second" {
  type        = number
  description = "Limits the bandwidth used by a DataSync task"
  default     = -1
}

variable "datasync_preserve_deleted_files" {
  type        = string
  description = "Specifies whether files in the destination location that don't exist in the source should be preserved"
  default     = "PRESERVE"
}

variable "datasync_overwrite_mode" {
  type        = string
  description = "Specifies whether DataSync should modify or preserve data at the destination location"
  default     = "ALWAYS"
}

variable "datasync_transfer_mode" {
  type        = string
  description = "The default states DataSync copies only data or metadata that is new or different content from the source location to the destination location"
  default     = "CHANGED"
}

variable "ssm_task_execution_parameter_arns" {
  type        = list(string)
  description = "Names of SSM parameters for adding to the task execution IAM role permissions"
  default     = []
}

variable "secrets_manager_task_execution_secret_arns" {
  type        = list(string)
  description = "List of Secrets Manager secrets to add to task execution permissions"
  default     = []
}

variable "datasync_s3_to_efs_pattern" {
  type        = string
  description = "Pattern to filter DataSync transfer task from S3 to EFS"
  default     = null
}

variable "iam_task_additional_policies" {
  type        = map(string)
  description = "Map of IAM Policies to add to the ECS task permissions. Values should be Policy ARNs; Keys are descriptive strings"
  default     = {}
}
