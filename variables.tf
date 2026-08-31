#tags
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "Terraform-Mastery"
}

variable "bucket_names" {
  type    = list(string)
  default = ["media", "logs"]
}

variable "resource_tags" {
  type = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "dev"
    Owner       = "platform-team"
  }
}