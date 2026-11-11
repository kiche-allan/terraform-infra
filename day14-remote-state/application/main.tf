terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-backend-allan-kiche-001"
    key          = "day14/application/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Read outputs from the networking state file
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state-backend-allan-kiche-001"
    key    = "day14/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use the VPC and subnet from networking layer
resource "aws_security_group" "web" {
  name   = "day14-web-sg"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

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

  tags = { Name = "day14-web-sg" }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.networking.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = { Name = "day14-web" }
}

output "instance_id" {
  value = aws_instance.web.id
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "vpc_used" {
  value = data.terraform_remote_state.networking.outputs.vpc_id
}