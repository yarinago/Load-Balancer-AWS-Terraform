terraform {
  required_version = ">= 1.3" # Terraform required version

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.14.0"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "aws" {
  region                  = var.region
  shared_credentials_files = [var.shared_credentials_files]
  profile                  = var.aws_profile
}

provider "docker" {}
