terraform {
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

variable "environment" {
  type    = string
  default = "test"
  validation {
    condition     = contains(["test", "staging", "prod"], var.environment)
    error_message = "Environment must be test, staging, or prod."
  }
}

variable "bucket_prefix" {
  type    = string
  default = "day29"
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_prefix}-${var.environment}-${random_id.suffix.hex}"
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
  
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name"  { value = aws_s3_bucket.main.bucket }
output "bucket_arn"   { value = aws_s3_bucket.main.arn }
output "environment"  { value = var.environment }