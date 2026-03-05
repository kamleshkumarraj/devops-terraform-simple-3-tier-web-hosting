variable "region" {
  default = "ap-south-1"
}


variable "ecr_repository_arn" {
  description = "ECR repository ARN"
}

variable "ecr_repository_arn_backend" {
  description = "ECR repository ARN"
}

variable "common_tags" {
  type = map(string)
  description = ""
}

variable "frontend_ec2_role_name" {
  type = string
  description = "The name of the IAM role to be attached to the frontend EC2 instances for accessing ECR"
  default = "frontend-ec2-ecr-role"
}

variable "backend_ecr_s3_access_role_name" {
  type = string
  description = "The name of the IAM role to be attached to the backend EC2 instances for accessing ECR and S3"
  default = "backend-ec2-ecr-s3-role"
}


variable "s3_bucket_name" {
  type = string
  description = "The name of the S3 bucket to which EC2 instances will upload data"
}

variable "bucket_arn" {
  type = string
  description = "The ARN of the S3 bucket to which EC2 instances will upload data"
}

variable "ssm_param_arn_frontend" {
  type = string
  description = "The ARN of the SSM parameter for frontend"
}

variable "ssm_param_arn_backend" {
  type = string
  description = "The ARN of the SSM parameter for backend"
}