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

# --- S3 bucket for remote state storage ---
resource "aws_s3_bucket" "terraform_state" {
  bucket = "day26-tfstate-${random_id.suffix.hex}"

  lifecycle {
    prevent_destroy = false
  }

  tags = { Name = "day26-terraform-state" }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- DynamoDB table for state locking ---
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "day26-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Name = "day26-terraform-locks" }
}

# --- Outputs (used to configure backend in other projects) ---
output "state_bucket_name" { value = aws_s3_bucket.terraform_state.bucket }
output "state_bucket_arn"  { value = aws_s3_bucket.terraform_state.arn }
output "dynamodb_table"    { value = aws_dynamodb_table.terraform_locks.name }
output "backend_config" {
  value = <<-EOT
    # Add this to any Terraform project to use this remote backend:
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.bucket}"
        key            = "project-name/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
      }
    }
  EOT
}