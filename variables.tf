// common varibale for whole project.
variable "availability_zones" {
  type = list(string)
  description = "List of availability zones to be used for the VPC"
}

variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to all resources"
}

variable "environment" {
  type = string
  description = "Environment name (dev, staging, production)"
  validation {
    condition = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "region" {
  type = string
  description = "AWS region where the VPC will be created"
}

// common varibale for vpc.
variable "cidr_range_vpc" {
  type = string
  description = "The CIDR range for the VPC"
}


// common varibale for ec2.
variable "ami_id" {
  type = string
  description = "The AMI ID to be used for the EC2 instance"
}

variable "instance_type" {
  type = string
  description = "The instance type for the EC2 instance"
}

variable "key_name" {
  type = string
  description = "The name of the key pair to be used for the EC2 instance"
}


variable "associate_public_ip_address" {
  type = bool
  description = "Whether to associate a public IP address with the EC2 instance"
}

variable "pem_file_path" {
  type = string
  description = "The path to the private key file for SSH access"
}

// common varibale for frontend auto launch template.
variable "frontend_lt_name" {
  type = string
  description = "The name of the frontend launch template"
}

variable "frontend_lt_ami_id" {
  type = string
  description = "The AMI ID to be used for the frontend launch template"
}

variable "frontend_lt_instance_type" {
  type = string
  description = "The instance type for the frontend launch template"
}

variable "frontend_lt_key_name" {
  type = string
  description = "The key name to be used for the frontend launch template"
}

variable "backend_lt_name" {
  type = string
  description = "The name of the backend launch template"
}

variable "backend_lt_ami_id" {
  type = string
  description = "The AMI ID to be used for the backend launch template"
}

variable "backend_lt_instance_type" {
  type = string
  description = "The instance type for the backend launch template"
}

variable "backend_lt_key_name" {
  type = string
  description = "The key name to be used for the backend launch template"
}

// arn related variables for iam module
variable "s3_bucket_name" {
  type = string
  description = "S3 bucket for uploads"
}

variable "ecr_repository_arn" {
  type = string
  description = "ECR repository ARN" 
}

variable "ecr_repository_arn_backend" {
  type = string
  description = "ECR repository ARN"
}

variable "scale_in_start_time" {
  type = string
  description = ""
}

variable "scale_out_start_time" {
  type = string
  description = ""
}

variable "bucket_name" {
  type = string
  description = "The name of the S3 bucket"
}

