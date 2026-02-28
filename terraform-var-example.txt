availability_zones = [ "ap-south-1a", "ap-south-1b" ]
cidr_range_vpc= ""
environment = "development"
region = "ap-south-1"
common_tags = {
  owner       = "devops-admin"
  environment = "development"
}

// common varibale for ec2.
# var.ami_id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id
#   associate_public_ip_address = var.associate_public_ip_address

ami_id = ""
instance_type = ""
key_name = ""
associate_public_ip_address = false
pem_file_path = ""

// common varibale for frontend auto launch template.
# var.frontend_lt_name
# var.frontend_lt_ami_id
# var.frontend_lt_instance_type
# var.frontend_lt_key_name  

frontend_lt_name = "ecommerce-frontend-lt"
frontend_lt_ami_id = ""
frontend_lt_instance_type = ""
frontend_lt_key_name = ""

backend_lt_name = "ecommerce-backend-lt"
backend_lt_ami_id = ""
backend_lt_instance_type = ""
backend_lt_key_name = ""


ecr_repository_arn = ""
ecr_repository_arn_backend = ""
s3_bucket_name = ""

scale_in_start_time = "2026-03-01T01:00:00Z"
scale_out_start_time = "2026-03-01T00:00:00Z"

bucket_name = ""