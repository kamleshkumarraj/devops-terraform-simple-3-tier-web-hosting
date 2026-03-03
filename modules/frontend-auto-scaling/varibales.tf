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


// now we define all asg related varibale.
variable "asg_name" {
  type = string
  default = "ecommerce-frontend-asg"
}

variable "frontend_min_size" {
  type = number
  default = 0
}

variable "frontend_max_size" {
  type = number
  default = 4
}

variable "frontend_desired_capacity" {
  type = number
  default = 1
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

variable "frontend_ec2_role_name" {
  type = string
  description = "The name of the IAM role to be attached to the frontend EC2 instances for accessing ECR and S3"

}

variable "scale_in_start_time" {
  type = string
  description = ""
}

variable "scale_out_start_time" {
  type = string
  description = ""
}


// frontend launch template sg variables
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "frontend_instance_name" {
  type        = string
  description = "Name of the frontend EC2 instance"
  default     = "frontend-ecommerce-server"
}



variable "frontend_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  description = "List of ingress rules for the security group"
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "frontend_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of egress rules for the security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}