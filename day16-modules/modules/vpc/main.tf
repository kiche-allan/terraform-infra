variable "vpc_cidr" {}
variable "subnet_cidr" {}
variable "environment" {}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.environment}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.subnet_cidr
  tags       = { Name = "${var.environment}-subnet" }
}

output "vpc_id" { value = aws_vpc.this.id }
output "subnet_id" { value = aws_subnet.public.id }
