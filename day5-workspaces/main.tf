terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = terraform.workspace
  bucket_name = "terraform-challenge-${local.environment}-ak-day5"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}