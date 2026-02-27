############################################
# BACKEND BUCKET (Logs / Uploads)
############################################

resource "aws_s3_bucket" "backend_bucket" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = local.s3_tags
}

resource "aws_s3_bucket_ownership_controls" "backend_ownership" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "backend_block" {
  bucket = aws_s3_bucket.backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_encryption" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backend_lifecycle" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    id     = "backend-log-retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 180
    }
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.backend_bucket.arn
}
