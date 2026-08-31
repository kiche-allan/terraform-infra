variable "environment" {
  type        = string
  description = "Deployment environment (dev or prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "List of ports for ingress rules"
}

variable "project_name" {
  type        = string
  default     = "Terraform-Mastery"
  description = "Project name rendered into the instance bootstrap page"
}