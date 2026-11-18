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

# --- IAM Role ---
# A role is an identity that AWS services can assume
resource "aws_iam_role" "ec2_role" {
  name = "day20-ec2-role"

  # Trust policy — who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = { Name = "day20-ec2-role" }
}

# --- IAM Policy ---
# Inline policy attached directly to the role
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "day20-ec2-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# --- Managed Policy Attachment ---
# Attach an AWS-managed policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- Instance Profile ---
# Wrapper that lets EC2 instances use the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "day20-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# --- Standalone IAM Policy (reusable) ---
resource "aws_iam_policy" "read_only" {
  name        = "day20-read-only-policy"
  description = "Read-only access to S3 and EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:Get*", "s3:List*", "ec2:Describe*"]
        Resource = "*"
      }
    ]
  })
}

# --- Outputs ---
output "role_arn"             { value = aws_iam_role.ec2_role.arn }
output "instance_profile_arn" { value = aws_iam_instance_profile.ec2_profile.arn }
output "read_only_policy_arn" { value = aws_iam_policy.read_only.arn }