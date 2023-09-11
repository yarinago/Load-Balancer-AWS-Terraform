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
  shared_credentials_files = ["~/.aws/creds"]
  profile                  = "beaconcure-terraform"
}

provider "docker" {}