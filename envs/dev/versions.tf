
terraform {
  required_version = ">= 1.1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.3"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.aws_profile_name
}

# Get our AWS Account ID
data "aws_caller_identity" "current" {
}
