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

# --- Variables to feed into functions ---
variable "environment" {
  default = "production"
}

variable "app_name" {
  default = "myapp"
}

variable "allowed_cidrs" {
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "instance_config" {
  default = {
    type    = "t3.micro"
    count   = 2
    region  = "us-east-1"
  }
}

# --- Locals demonstrating built-in functions ---
locals {
  # String functions
  env_upper     = upper(var.environment)
  env_lower     = lower(var.environment)
  name_trimmed  = trimspace("  ${var.app_name}  ")
  name_replaced = replace(var.app_name, "-", "_")
  full_name     = "${var.app_name}-${var.environment}"
  name_length   = length(var.app_name)

  # Numeric functions
  max_instances = max(2, 4, 1, 8, 3)
  min_instances = min(2, 4, 1, 8, 3)
  abs_value     = abs(-42)

  # Collection functions
  cidr_count    = length(var.allowed_cidrs)
  first_cidr    = element(var.allowed_cidrs, 0)
  sorted_cidrs  = sort(var.allowed_cidrs)
  merged_tags   = merge(
    { Environment = var.environment },
    { App = var.app_name },
    { ManagedBy = "Terraform" }
  )
  flat_list     = flatten([["a", "b"], ["c", "d"], ["e"]])

  # Encoding functions
  b64_name      = base64encode(var.app_name)
  json_config   = jsonencode(var.instance_config)

  # Date/time
  current_time  = timestamp()

  # Conditional
  is_prod       = var.environment == "production" ? true : false
  instance_type = var.environment == "production" ? "t3.medium" : "t3.micro"
}

# --- S3 bucket using functions in its config ---
resource "aws_s3_bucket" "app" {
  bucket = "${lower(var.app_name)}-${lower(var.environment)}-${formatdate("YYYYMMDD", timestamp())}"
  tags   = local.merged_tags
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Security group using cidrsubnet and collection functions ---
resource "aws_security_group" "app" {
  name        = "${local.full_name}-sg"
  description = "Security group for ${local.full_name}"

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "HTTPS from ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.merged_tags
}

# --- Outputs showing function results ---
output "string_functions" {
  value = {
    upper    = local.env_upper
    lower    = local.env_lower
    trimmed  = local.name_trimmed
    replaced = local.name_replaced
    length   = local.name_length
  }
}

output "numeric_functions" {
  value = {
    max = local.max_instances
    min = local.min_instances
    abs = local.abs_value
  }
}

output "collection_functions" {
  value = {
    cidr_count   = local.cidr_count
    first_cidr   = local.first_cidr
    sorted_cidrs = local.sorted_cidrs
    flat_list    = local.flat_list
  }
}

output "encoding_functions" {
  value = {
    base64   = local.b64_name
    json     = local.json_config
  }
}

output "conditional_logic" {
  value = {
    is_prod       = local.is_prod
    instance_type = local.instance_type
  }
}

output "merged_tags"   { value = local.merged_tags }
output "bucket_name"   { value = aws_s3_bucket.app.bucket }
output "sg_name"       { value = aws_security_group.app.name }