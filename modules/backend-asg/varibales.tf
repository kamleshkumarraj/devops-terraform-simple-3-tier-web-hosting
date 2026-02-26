variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to all resources in the backend auto scaling module"
}

variable "backend_lt_name" {
  type = string
  description = "Name of the launch template for the backend auto scaling group"
  default = "ecommerce-backend-lt"
}

variable "fronetnd_lt_ami_id" {
  type = string
  description = "The AMI ID to be used for the backend launch template"
}

variable "backend_lt_instance_type" {
  type = string
  description = "The instance type for the backend launch template"
  default = "t2.small"
}

variable "backend_lt_key_name" {
  type = string
  description = "The key name to be used for the backend launch template"
}

variable "backend_sg" {
    type = string
    description = "The security group ID for the backend auto scaling group"
}

// now we define all asg related varibale.
variable "asg_name" {
  type = string
  default = "ecommerce-backend-asg"
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


