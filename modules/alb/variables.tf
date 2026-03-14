variable "common_tags" {
  type = map(string)
  default = {
    "author" = "devops-admin"
    "environment" = "development"
  }
}

variable "alb_public_subnet" {
  type = list(string)
  description = "The list of subnet IDs where the ALB is deployed"
}

variable "alb_private_subnet" {
  type = list(string)
  description = "The list of subnet IDs where the internal ALB is deployed"
}

variable "vpc_id" {
  type = string
  description = "The VPC ID where the ALB is deployed"
}


variable "backend_cidr_blocks" {
  type = list(string)
  description = "The CIDR blocks allowed to access the backend ALB"
}

variable "domain_name" {
  description = "Domain for SSL certificate"
  type        = string
  default = "viharfood.in"
}

variable "zone_id" {
  description = "Route53 hosted zone id"
  type        = string
  default = "Z05892463BEMCWHVXXLAS"
}


