variable "region" {
  default = "ap-south-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket for uploads"
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN"
}

variable "common_tags" {
  type = map(string)
  description = ""
}