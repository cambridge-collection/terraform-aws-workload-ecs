# NOTE Terraform will throw an error if a sensitive variable is used directly in for_each
resource "aws_s3_object" "env_object" {
  for_each = nonsensitive(toset(keys(var.s3_env_objects)))
  bucket   = var.s3_env_bucket
  key      = each.key
  content  = var.s3_env_objects[each.key]
}

resource "aws_s3_object" "data_source_object" {
  for_each = nonsensitive(toset(keys(var.s3_data_source_objects)))
  bucket   = var.s3_data_source_bucket
  key      = each.key
  content  = var.s3_data_source_objects[each.key]
}
