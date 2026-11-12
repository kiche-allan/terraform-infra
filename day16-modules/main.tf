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

module "dev_vpc" {
  source      = "./modules/vpc"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

module "prod_vpc" {
  source      = "./modules/vpc"
  environment = "prod"
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
}

module "dev_sg" {
  source      = "./modules/security-group"
  environment = "dev"
  vpc_id      = module.dev_vpc.vpc_id
}

module "prod_sg" {
  source      = "./modules/security-group"
  environment = "prod"
  vpc_id      = module.prod_vpc.vpc_id
}

output "dev_vpc_id" { value = module.dev_vpc.vpc_id }
output "prod_vpc_id" { value = module.prod_vpc.vpc_id }
output "dev_sg_id" { value = module.dev_sg.sg_id }
output "prod_sg_id" { value = module.prod_sg.sg_id }
