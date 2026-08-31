module "web_cluster" {
  source        = "./modules/web_cluster"
  environment   = var.environment
  project_name  = var.project_name
  vpc_id        = data.aws_vpc.default.id
  subnet_ids    = data.aws_subnets.default.ids
  ingress_ports = [80, 443]
}

locals {
  resource_tags = merge(var.resource_tags, {
    Project = var.project_name
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_storage" {
  for_each = toset(var.bucket_names)
  bucket   = "${var.environment}-${each.value}-${random_id.bucket_suffix.hex}"
  tags     = local.resource_tags
}