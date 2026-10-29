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

# count example — creates 3 buckets by index
resource "aws_s3_bucket" "count_buckets" {
  count  = 3
  bucket = "terraform-ak-day7-count-${count.index}"
  tags = {
    ManagedBy = "Terraform"
    Index     = count.index
  }
}

# for_each example — creates buckets by name
resource "aws_s3_bucket" "foreach_buckets" {
  for_each = toset(["dev", "staging", "prod"])
  bucket   = "terraform-ak-day7-${each.key}"
  tags = {
    ManagedBy   = "Terraform"
    Environment = each.key
  }
}