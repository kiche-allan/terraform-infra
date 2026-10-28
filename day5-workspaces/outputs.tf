output "workspace" {
  value = terraform.workspace
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}