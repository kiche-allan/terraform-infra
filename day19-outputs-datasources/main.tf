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

# --- Data Sources ---
# Query existing AWS infrastructure without managing it

# Get current AWS account info
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get available AZs in this region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC (every AWS account has one)
data "aws_vpc" "default" {
  default = true
}

# --- Resources using data source values ---

resource "aws_security_group" "web" {
  name        = "day19-web-sg"
  description = "Web security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "day19-web-sg" }
}

# --- Outputs ---

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID"
}

output "region" {
  value       = data.aws_region.current.name
  description = "Current AWS region"
}

output "availability_zones" {
  value       = data.aws_availability_zones.available.names
  description = "Available AZs"
}

output "latest_ami_id" {
  value       = data.aws_ami.amazon_linux.id
  description = "Latest Amazon Linux 2 AMI ID"
}

output "latest_ami_name" {
  value       = data.aws_ami.amazon_linux.name
  description = "Latest Amazon Linux 2 AMI name"
}

output "default_vpc_id" {
  value       = data.aws_vpc.default.id
  description = "Default VPC ID"
}

output "default_vpc_cidr" {
  value       = data.aws_vpc.default.cidr_block
  description = "Default VPC CIDR"
}

output "sg_id" {
  value       = aws_security_group.web.id
  description = "Security group ID"
}

# Sensitive output — masked in terminal, still usable by other configs
output "account_arn" {
  value       = data.aws_caller_identity.current.arn
  description = "Caller ARN"
  sensitive   = true
}