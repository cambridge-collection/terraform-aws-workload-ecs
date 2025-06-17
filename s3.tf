# NOTE Terraform will throw an error if a sensitive variable is used directly in for_each
resource "aws_s3_object" "task_execution" {
  for_each = nonsensitive(toset(keys(var.s3_task_execution_bucket_objects)))
  bucket   = var.s3_task_execution_bucket
  key      = each.key
  content  = var.s3_task_execution_bucket_objects[each.key]
}

resource "aws_s3_object" "task" {
  for_each = length(var.s3_task_buckets) > 0 ? nonsensitive(toset(keys(var.s3_task_bucket_objects))) : []
  bucket   = var.s3_task_buckets[0]
  key      = each.key
  content  = var.s3_task_bucket_objects[each.key]
}

resource "aws_s3_bucket" "cloudfront_bucket" {
  count = var.cloudfront_distribution_create && length(var.cloudfront_custom_error_pages_list) > 0 ? 1 : 0

  bucket        = "${var.name_prefix}-cloudfront-bucket"
  force_destroy = false
}

locals {
  cloudfront_custom_error_pages_map = {
    for page in var.cloudfront_custom_error_pages_list : page.error_code => page
  }
}

resource "aws_s3_object" "error_pages" {
  for_each     = local.cloudfront_custom_error_pages_map
  bucket       = aws_s3_bucket.cloudfront_bucket[0].id
  key          = trim(each.value.path, "/")
  content      = each.value.content
  content_type = "text/html"

  depends_on = [aws_s3_bucket.cloudfront_bucket]
}