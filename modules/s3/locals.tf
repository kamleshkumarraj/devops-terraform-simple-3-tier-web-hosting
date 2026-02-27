locals {
  common_tags = var.common_tags

  s3_tags = merge(
    var.common_tags,
    {
      "Name" : var.bucket_name
    }
  )
}