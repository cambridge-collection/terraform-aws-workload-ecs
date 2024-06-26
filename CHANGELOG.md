# Changelog

All notable changes to this project will be documented in this file. See
[Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
