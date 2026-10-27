terraform {
  required_version = ">= 1.0.0"
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

module "dev_bucket" {
  source      = "./modules/s3-bucket"
  bucket_name = "terraform-challenge-dev-ak-day4"
  environment = "dev"
}

module "prod_bucket" {
  source      = "./modules/s3-bucket"
  bucket_name = "terraform-challenge-prod-ak-day4"
  environment = "prod"
}
