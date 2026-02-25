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



