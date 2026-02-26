// we create first launch template.

resource "aws_launch_template" "ecommerce_fronetend_lt" {
  name = var.frontend_lt_name

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  # cpu_options {
  #   core_count       = 4
  #   threads_per_core = 2
  # }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = false
  disable_api_termination = false

  ebs_optimized = true

  iam_instance_profile {
    name = "test"
  }

  image_id = var.fronetnd_lt_ami_id

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "on_demand"
  }

  instance_type = var.frontend_lt_instance_type

  # kernel_id = "test"

  key_name = var.frontend_lt_key_name


  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  # placement {
  #   availability_zone = "us-west-2a"
  # }

  # ram_disk_id = "test"

  vpc_security_group_ids = [var.frontend_sg]

  tag_specifications {
    resource_type = "instance"

    tags = local.ft_launch_template_tags
  }

  user_data = filebase64("${path.module}/application_setup.sh")
}

// now we cretae auto scaling group for frontend.