variable "common_tags" {
  type = map(string)
  default = {
    "author" = "devops-admin"
    "environment" = "development"
  }
}

variable "alb_subnet" {
  type = list(string)
  description = "The list of subnet IDs where the ALB is deployed"
}

variable "vpc_id" {
  type = string
  description = "The VPC ID where the ALB is deployed"
}