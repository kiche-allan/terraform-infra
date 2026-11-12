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

locals {
  # terraform.workspace is a built-in variable — the current workspace name
  instance_type = {
    default = "t2.micro"
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }

  common_tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Project     = "day17-workspaces"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "${terraform.workspace}-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags       = merge(local.common_tags, { Name = "${terraform.workspace}-subnet" })
}

resource "aws_security_group" "web" {
  name   = "${terraform.workspace}-web-sg"
  vpc_id = aws_vpc.main.id

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

  tags = local.common_tags
}

output "workspace"    { value = terraform.workspace }
output "vpc_id"       { value = aws_vpc.main.id }
output "instance_type" { value = local.instance_type[terraform.workspace] }