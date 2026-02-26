module "vpc" {
  source = "./modules/vpc"
  availability_zones = var.availability_zones
  cidr_block = var.cidr_range_vpc
  environment = var.environment
  region = var.region

}

module "ec2" {
  source = "./modules/ec2"
  common_tags = var.common_tags
  ami_id = var.ami_id
  key_name = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = module.vpc.private_subnet_id
  vpc_id = module.vpc.vpc_id
  pem_file_path = var.pem_file_path
  cidr_range_vpc = var.cidr_range_vpc
}


module "frontend-auto-scaling" {
  source = "./modules/frontend-auto-scaling"
  common_tags = var.common_tags
  frontend_lt_name = var.frontend_lt_name
  frontend_lt_instance_type = var.frontend_lt_instance_type
  frontend_lt_key_name = var.frontend_lt_key_name
  frontend_sg = module.ec2.frontend_sg_id
  asg_subnet = module.vpc.private_subnet_id
  frontend_lt_ami_id = var.frontend_lt_ami_id

}



module "backend-auto-scaling" {
  source = "./modules/backend-asg"
  common_tags = var.common_tags
  backend_lt_name = var.backend_lt_name
  backend_lt_instance_type = var.backend_lt_instance_type
  backend_lt_key_name = var.backend_lt_key_name
  backend_sg = module.ec2.backend_sg_id
  asg_subnet = module.vpc.private_subnet_id
  backend_lt_ami_id = var.backend_lt_ami_id

}

