# https://dev.to/thnery/create-an-aws-ecs-cluster-using-terraform-g80 

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }

  backend "s3" {} // this is called partial configuration https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration
}

provider "aws" {
    region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}
