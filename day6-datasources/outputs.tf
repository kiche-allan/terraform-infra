output "bucket_arn_from_resource" {
  value       = aws_s3_bucket.primary.arn
  description = "ARN from the resource block"
}

output "bucket_arn_from_data" {
  value       = data.aws_s3_bucket.primary_lookup.arn
  description = "ARN from the data source lookup"
}

output "bucket_region" {
  value       = data.aws_s3_bucket.primary_lookup.region
  description = "Region from data source"
}