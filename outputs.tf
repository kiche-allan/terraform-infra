output "instance_id" {
  value = module.web_cluster.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the web instance"
  value       = module.web_cluster.instance_public_ip
}

output "created_buckets" {
  description = "List of bucket ARNs created via for_each"
  value       = [for b in aws_s3_bucket.app_storage : b.arn]
}