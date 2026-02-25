variable "region" {
  type = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type = string
  validation {
    condition = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}



variable "cidr_block" {
  type = string
  description = "CIDR block for the VPC"
}


variable "availability_zones" {
  type = list(string)
}