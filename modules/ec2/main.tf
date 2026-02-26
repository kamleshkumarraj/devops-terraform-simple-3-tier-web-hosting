// first we create a key pair to access our EC2 instances. The public key is stored in the same directory as this module.


// now we create a security group to allow inbound traffic on port 80 for our web server and port 22 for SSH access.
resource "aws_security_group" "ec2_sg_frontend" {
  name   = "${var.frontend_instance_name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.frontend_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.frontend_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.frontend_server_sg_tags
}

// now we create sg for backend server to allow traffic only from frontend server security group on port 3306 for MySQL database.
resource "aws_security_group" "ec2_sg_backend" {
  name   = "${var.backend_instance_name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.backend_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.backend_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.backend_server_sg_tags
}

resource "aws_security_group" "ec2_sg_database" {
  name   = "${var.db_instance_name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.db_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.db_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.db_server_sg_tags
}

output "frontend_sg_id" {
  value = aws_security_group.ec2_sg_frontend.id
}

output "backend_sg_id" {
  value = aws_security_group.ec2_sg_backend.id
}

output "database_sg_id" {
  value = aws_security_group.ec2_sg_database.id
}

# resource "aws_instance" "frontend_web_server" {
#   count                       = 2
#   ami                         = var.ami_id
#   instance_type               = var.frontend_instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id[count.index]
#   associate_public_ip_address = var.associate_public_ip_address
#   vpc_security_group_ids      = [aws_security_group.ec2_sg_frontend.id]

#   tags = merge(var.common_tags, {
#     Name = "${var.frontend_instance_name}-${count.index + 1}"
#   })

  
# }

# resource "aws_instance" "backend_web_server" {
#   count                       = 2
#   ami                         = var.ami_id
#   instance_type               = var.backend_instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id[count.index]
#   associate_public_ip_address = var.associate_public_ip_address
#   vpc_security_group_ids      = [aws_security_group.ec2_sg_backend.id]

#   tags = merge(var.common_tags, {
#     Name = "${var.backend_instance_name}-${count.index + 1}"
#   })

  
# }

# resource "aws_instance" "database_server" {
#   count = 1
#   ami                         = var.ami_id
#   instance_type               = var.db_instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id[0]
#   associate_public_ip_address = var.associate_public_ip_address
#   vpc_security_group_ids      = [aws_security_group.ec2_sg_database.id]

#   tags = merge(var.common_tags, {
#     Name = "${var.db_instance_name}-1"
#    })
  
#   root_block_device {
#     volume_size           = var.db_storage_size
#     volume_type           = "gp3"
#     encrypted             = true
#     delete_on_termination = var.db_instance_storage_protection
#   }
# }

