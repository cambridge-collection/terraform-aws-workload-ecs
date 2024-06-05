terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.44.0"
      configuration_aliases = [aws.us-east-1]
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.3"
    }
  }
}
