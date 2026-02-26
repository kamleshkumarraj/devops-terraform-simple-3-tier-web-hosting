variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to all resources in the frontend auto scaling module"
}

variable "frontend_lt_name" {
  type = string
  description = "Name of the launch template for the frontend auto scaling group"
  default = "ecommerce-frontend-lt"
}

variable "frontend_lt_ami_id" {
  type = string
  description = "The AMI ID to be used for the frontend launch template"
}

variable "frontend_lt_instance_type" {
  type = string
  description = "The instance type for the frontend launch template"
  default = "t2.micro"
}

variable "frontend_lt_key_name" {
  type = string
  description = "The key name to be used for the frontend launch template"
}

variable "frontend_sg" {
    type = string
    description = "The security group ID for the frontend auto scaling group"
}

// now we define all asg related varibale.
variable "asg_name" {
  type = string
  default = "ecommerce-frontend-asg"
}

variable "min_size" {
  type = number
  default = 0
}

variable "max_size" {
  type = number
  default = 3
}

variable "desired_capacity" {
  type = number
  default = 0
}

variable "health_check_gp" {
  type = number
  default = 300
}

variable "health_check_type" {
  type = string
  default = "ELB"
}

variable "asg_subnet" {
  type = list(string)
  description = ""
}


variable "frontend_tg_arn" {
  type = string
}

