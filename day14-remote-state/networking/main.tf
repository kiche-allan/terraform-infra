terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-backend-allan-kiche-001"
    key          = "day14/networking/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "day14-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "day14-public-subnet" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "day14-igw" }
}

# These outputs are what the application layer will read
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID for application layer"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID for application layer"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}