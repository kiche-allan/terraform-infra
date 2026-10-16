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

resource "aws_s3_bucket" "my_first" {
  bucket = "terraform-challenge-allan-kiche-001"

  tags = {
    Name        = "My First Terraform Bucket"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_first.bucket
}