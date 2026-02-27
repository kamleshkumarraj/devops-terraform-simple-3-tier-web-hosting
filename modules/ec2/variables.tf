variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "frontend_instance_name" {
  type        = string
  description = "Name of the frontend EC2 instance"
  default     = "frontend-ecommerce-server"
}

variable "backend_instance_name" {
  type        = string
  description = "Name of the backend EC2 instance"
  default     = "backend-ecommerce-server"
}

variable "db_instance_name" {
  type        = string
  description = "Name of the database EC2 instance"
  default     = "db-ecommerce-server"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "frontend_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
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

// now we create sg for database server to allow traffic only from backend server security group on port 27017 for MongoDB database.
variable "db_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of ingress rules for the database security group"
  default = [
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "db_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of egress rules for the database security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


// insatnce specific variables for ec2 module.
variable "cidr_range_vpc" {
  type        = string
  description = "The CIDR range for the VPC"
}


// common varibale for ec2.
variable "ami_id" {
  type        = string
  description = "The AMI ID to be used for the EC2 instance"
}


variable "key_name" {
  type        = string
  description = "The name of the key pair to be used for the EC2 instance"
}


variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with the EC2 instance"
}

variable "subnet_id" {
  type        = list(string)
  description = "The subnet ID where the EC2 instance will be launched"
}

variable "pem_file_path" {
  type        = string
  description = "The path to the private key file for SSH access"

}

variable "frontend_instance_type" {
  type        = string
  description = "The instance type for the EC2 instance"
  default     = "t3.micro"
}

variable "backend_instance_type" {
  type        = string
  description = "The instance type for the EC2 instance"
  default     = "t3.micro"
}


variable "db_storage_size" {
  type        = number
  description = "The size of the EBS volume for the database instance in GB"
  default     = 40

}

variable "db_instance_type" {
  type        = string
  description = "The instance type for the database EC2 instance"
  default     = "t3.small"
}

variable "db_instance_storage_protection" {
  type        = bool
  description = "Whether to enable instance protection for the database EC2 instance"
  default     = false
}


