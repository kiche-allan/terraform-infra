# Query existing AWS VPC. 
data "aws_vpc" "default" {
  default = true
}

# Query subnets in default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}