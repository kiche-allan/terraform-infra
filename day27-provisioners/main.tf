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

# --- null_resource: runs local commands without creating AWS resources ---
resource "null_resource" "setup" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Terraform provisioner running at ${timestamp()}'"
  }
}

# --- local-exec: generate a config file locally ---
resource "null_resource" "generate_config" {
  provisioner "local-exec" {
    command = <<-EOT
      echo '[app-config]' > app-config.ini
      echo 'environment = day27' >> app-config.ini
      echo 'region = us-east-1' >> app-config.ini
      echo 'generated_at = ${timestamp()}' >> app-config.ini
      echo 'Config file generated successfully'
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cleaning up day27 resources'"
  }
}

# --- S3 bucket + local-exec to record bucket name ---
resource "aws_s3_bucket" "app" {
  bucket = "day27-app-${random_id.suffix.hex}"
  tags   = { Name = "day27-app-bucket" }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "null_resource" "post_bucket" {
  depends_on = [aws_s3_bucket.app]

  provisioner "local-exec" {
    command = "echo 'S3 bucket created: ${aws_s3_bucket.app.bucket}' > bucket-info.txt"
  }
}

# --- Outputs ---
output "bucket_name"  { value = aws_s3_bucket.app.bucket }
output "bucket_arn"   { value = aws_s3_bucket.app.arn }