# Look up the latest Amazon Linux 2023 AMI instead of hardcoding an ID
data "aws_ami" "web" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Dynamic blocks for security group rules
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.environment}-web-sg-"
  vpc_id      = var.vpc_id
  description = "Web security group"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Conditional expression for instance sizing and lifecycle rules
resource "aws_instance" "web" {
  ami           = data.aws_ami.web.id
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
  subnet_id     = var.subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    project_name = var.project_name
    environment  = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
}