terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    local = {
      source  = "hashicorp/local"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

