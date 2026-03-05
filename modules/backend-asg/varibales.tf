variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to all resources in the backend auto scaling module"
}

variable "backend_lt_name" {
  type = string
  description = "Name of the launch template for the backend auto scaling group"
  default = "ecommerce-backend-lt"
}

variable "backend_lt_ami_id" {
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
  default = 4
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

variable "backend_tg_arn" {
  type = string
  description = "The ARN of the backend target group"
}

variable "scale_in_start_time" {
  type = string
  description = ""
}

variable "scale_out_start_time" {
  type = string
  description = ""
}

variable "backend_ecr_s3_access_role" {
  type = string
  description = ""
}

variable "backend_instance_name" {
  type        = string
  description = "Name of the backend EC2 instance"
  default     = "backend-ecommerce-server"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

// now we create sg for backend server to allow traffic only from frontend server security group on port 3306 for MySQL database.
variable "backend_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of ingress rules for the backend security group"
  default = [
    {
      from_port   = 4000
      to_port     = 4000
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

variable "backend_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of egress rules for the backend security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

