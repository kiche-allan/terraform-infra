terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
        random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- Implicit dependency (automatic) ---
# Terraform sees aws_vpc.main.id referenced inside the subnet
# and automatically creates the VPC first
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "day13-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id   # implicit dependency
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "day13-subnet" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id   # implicit dependency

  tags = { Name = "day13-igw" }
}

# --- Explicit dependency with depends_on ---
# Route table has no direct reference to the IGW in its body,
# but it must not exist before the IGW is attached to the VPC.
# Without depends_on, Terraform might create these in parallel.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # this creates an implicit dep too
  }

  tags = { Name = "day13-rt" }
}

# S3 bucket for logs — no reference to VPC resources at all
# but we want it created before the VPC for ordering demo
resource "aws_s3_bucket" "logs" {
  bucket = "day13-logs-${random_id.suffix.hex}"

  tags = { Name = "day13-logs" }

  # explicit dependency — no code reference exists, but we force ordering
  depends_on = [aws_vpc.main]
}

resource "random_id" "suffix" {
  byte_length = 4
}

# --- IAM role + policy attachment (classic depends_on use case) ---
resource "aws_iam_role" "ec2_role" {
  name = "day13-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

  # implicit dependency via aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "day13-ec2-profile"
  role = aws_iam_role.ec2_role.name

  # must wait for role AND policy attachment to be complete
  depends_on = [aws_iam_role_policy_attachment.ec2_ssm]
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}