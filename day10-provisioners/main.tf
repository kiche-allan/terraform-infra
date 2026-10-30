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

# Generate an SSH key pair in Terraform
resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS
resource "aws_key_pair" "web" {
  key_name   = "day10-web-key"
  public_key = tls_private_key.web.public_key_openssh
}

# Save the private key locally so Terraform can SSH in
resource "local_file" "private_key" {
  content         = tls_private_key.web.private_key_pem
  filename        = "${path.module}/day10-key.pem"
  file_permission = "0600"
}

data "aws_vpc" "main" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name   = "day10-web-sg"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnets.public.ids)[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.web.key_name
  associate_public_ip_address = true

  tags = {
    Name      = "day10-provisioner-web"
    ManagedBy = "Terraform"
  }

  # file provisioner — copies a file from local machine to the instance
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.web.private_key_pem
      host        = self.public_ip
    }
  }

  # remote-exec provisioner — runs commands on the instance via SSH
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y httpd",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.web.private_key_pem
      host        = self.public_ip
    }
  }

  # local-exec provisioner — runs a command on YOUR machine, not the instance
  provisioner "local-exec" {
    command = "echo Instance ${self.public_ip} is ready >> provisioner-log.txt"
  }
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}