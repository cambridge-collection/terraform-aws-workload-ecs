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
