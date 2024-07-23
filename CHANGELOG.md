# Changelog

All notable changes to this project will be documented in this file. See
[Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [2.2.0](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v2.1.1...v2.2.0) (2024-07-23)


### Features

* **appautoscaling:** Remove aws_appautoscaling_policy.ecs ([49cac2d](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/49cac2db2c87a1471f45f282019f7bf3b857be92))
* **ecs:** Add capacity_provider_strategy block to aws_ecs_service ([c215d16](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/c215d16abdd4eb95e7fe7a11bf2d9d84861f82ff))
* **ecs:** Add input ecs_service_scheduling_strategy ([c7cdddb](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/c7cdddb75eef00c0cf79677de453faa7c3a481f5))

## [2.1.1](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v2.1.0...v2.1.1) (2024-07-23)


### Bug Fixes

* **ecs:** Set deployment properties of ECS service using inputs ([81edf9c](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/81edf9cc982e3acc09a725e2e9f89468c3e703aa))

## [2.1.0](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v2.0.1...v2.1.0) (2024-07-19)


### Features

* **ecs:** Add network_configuration block to aws_ecs_service.this ([98b2076](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/98b20769496750b4e61b8f0da4e9c013bf57fb6f))


### Bug Fixes

* **asg:** Add count to aws_autoscaling_attachment resource based on ecs_network_mode input ([ef765e2](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/ef765e2df50c53422210ea4c658379b78217ca2e))
* **ecs:** Add condition to container_port argument of service_registries in aws_ecs_service.this ([56cf781](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/56cf7816d300060eab9ebfc49e4e90050b79dac5))
* **lb:** Fix target type for aws_lb_target_group when network mode is awsvpc ([d114437](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/d114437658a59a790945b9be0f926d71ccc53939))

## [2.0.1](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v2.0.0...v2.0.1) (2024-07-15)


### Bug Fixes

* **efs:** Add precondition blocks to EFS resources ([ae99b81](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/ae99b8108477a2037ff89d84c86c91f86f0449ff))

## [2.0.0](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v1.1.0...v2.0.0) (2024-07-12)


### ⚠ BREAKING CHANGES

* **iam:** input s3_task_bucket renamed to s3_task_buckets
* **ecs:** Input variable ecs_cluster_name removed

### Bug Fixes

* **acm:** Validate domain name ([c384433](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/c38443318db31832e383bc15ac800f7786b6ec2a))
* **ecs:** Address potentially invalid ecs_cluster_name ([28531dc](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/28531dc5779f97d00584322a3730917675e8d6fd))
* **iam:** Fix error with count values ([286d522](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/286d5227539f3c8a626e5b12a3010a2f4184a8d5))
* **iam:** Fix malformed policy document error on Task IAM policy ([6759486](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/6759486a354e609a9b8c804404c34b007aa0e25d))
* **security:** Add precondition to aws_security_group_rule.asg_ingress_private_access ([6a9c3c3](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/6a9c3c32f2569415a97710cafd9ff6a3217a1154))

## [1.1.0](https://github.com/cambridge-collection/terraform-aws-workload-ecs/compare/v1.0.0...v1.1.0) (2024-06-18)


### Features

* **cloudmap:** Add route 53 zone associations for Cloud Map ([c7f5cc7](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/c7f5cc7d54ddc9cf6784ff818b98ca8f413a5821))
* **security:** Remove private_access security group ([121bf86](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/121bf86d29d7ede3919252e144cf32fc9cc6bf92))


### Bug Fixes

* **datasync:** Add dependency on EFS mount targets in aws_datasync_location_efs resources ([64ec243](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/64ec24350ea22fc2bd4fbeb04684ef1ea8d7a618))
* **iam:** Fix error building permissions for DataSync ([a219906](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/a219906b13e5af717e2348c49fbda784032daac4))
* **s3:** Fix error with for_each loop on aws_s3_object resources ([c40c90d](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/c40c90df4655c12c54ed102dc24cac3dbe1d87a8))
* **security:** Add null default value to ingress_security_group_id variable ([2c0ed60](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/2c0ed604fd06a1b01d09ff2a77c7e3da4bd78f52))

## 1.0.0 (2024-06-05)


### ⚠ BREAKING CHANGES

* **s3:** inputs s3_env_bucket and s3_env_objects have been
replaced

### Features

* **datasync:** Add aws_security_group_rule.efs_egress_nfs_to_vpc ([417c2b9](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/417c2b91cb5db507fb3aaa1bc212faa467c3de3f))
* **datasync:** Add DataSync resources ([66a6fb8](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/66a6fb8c168b4fb8241ac910c1783e1274a85b4e))
* **datasync:** Add ipv6 cidr blocks argument to aws_security_group_rule.efs_ingress_nfs_from_s3 ([a5b6b02](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/a5b6b02ab3e61dae32a989d8aab0ee10ca2b55a5))
* **datasync:** Add variables for datasync task ([a6235da](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/a6235da1074cb2980430aa4005d77e3b810da548))
* **datasync:** Create security group rule for EFS for DataSync ([e46e693](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/e46e69346271b729a9a7ea6e02cf64f54d6f56d2))
* **datasync:** Refactor aws_security_group_rule.efs_ingress_nfs_from_s3 to use vpc cidr ([d936f2c](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/d936f2c8cdaf9386074b749a4f23f796182e2276))
* **datasync:** Refactor S3 subdirectory source ([bf6bcc4](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/bf6bcc410938240660aae6007fb33647438be677))
* **datasync:** Use prefix list for S3 ingress ([72fb518](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/72fb518375f66af7f7a02ae7d72ff814db24c89f))
* **efs:** Add EFS Access Point ([cd3b706](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/cd3b706217b3ef14189ff87091df821503568d08))
* **efs:** Add optional EFS file system to task definition ([ff96f27](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/ff96f271db3e6cc5f517673477b12d3c0e2f7d91))
* **efs:** Add security group for EFS mount target ([0ae62a2](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/0ae62a28eff8a23e8ce39c7120d4e647c2167e4c))
* **efs:** Adjust conditions on EFS volume in task definition ([a4dc3da](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/a4dc3dadde1b7a4a426967d915cc3ca2e46c330d))
* **efs:** Update default values for variables ([d989ee0](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/d989ee0e51db6ff7a15ed28d34e95ac7d3ce3135))
* **iam:** Add elasticfilesystem permissions to task role ([49f1bed](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/49f1bed637e04f7ec6038d2da31d0908808e5abb))
* Initial commit from template ([7384085](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/738408500b5aa18d4df44da660f0d5ebe3afe231))
* **s3:** Refactor inputs for S3 ([2c1001a](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/2c1001a7d5a1d3ed0e1a1719dac01730b45adb0f))
* **s3:** Rename inputs for S3 service bucket ([e4ab795](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/e4ab79555ed5cd8a2676bbbe9656e1125774b295))
* **tf:** Add Terraform code ([0cf5a1f](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/0cf5a1f8a680ab75361ef47e1977c330bc311dee))
* **tf:** Run Terraform fmt ([8ff4e0f](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/8ff4e0f2a2aae759377f9637a5f37f5bb75e1082))
* **tf:** Terraform refactoring ([6821496](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/68214962755ecfc030568699fae694afe7c58bdf))
* **workflow:** Add code for GitHub workflows ([5b55343](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/5b553434d6ec3269f6d8d1d25bc4be04cd1db7dc))


### Bug Fixes

* **outputs:** Add depends_on reference to data.external.route53_a_record ([d9fb46b](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/d9fb46b16d86ecd0cf25be1f1fca3ad9a971506a))
* **outputs:** Use try function for output private_access_host in case of failure ([e19b520](https://github.com/cambridge-collection/terraform-aws-workload-ecs/commit/e19b5203ae15b90f0d55ed5329fce29267957ff4))
