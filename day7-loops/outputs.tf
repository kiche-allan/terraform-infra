output "count_bucket_names" {
  value = [for b in aws_s3_bucket.count_buckets : b.bucket]
}

output "foreach_bucket_names" {
  value = { for k, b in aws_s3_bucket.foreach_buckets : k => b.bucket }
}