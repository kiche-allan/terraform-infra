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

# Create a bucket
resource "aws_s3_bucket" "primary" {
  bucket = "terraform-challenge-ak-day6-primary"
  tags = {
    ManagedBy = "Terraform"
  }
}

# Read back the bucket we just created using a data source
data "aws_s3_bucket" "primary_lookup" {
  bucket     = aws_s3_bucket.primary.bucket
  depends_on = [aws_s3_bucket.primary]
}