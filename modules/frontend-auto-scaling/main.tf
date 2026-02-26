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

resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "ecommerce_frontend_asg" {
  name                      = var.asg_name
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_gp
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete              = true
  placement_group           = aws_placement_group.test.id
  launch_template {
  id      = aws_launch_template.ecommerce_fronetend_lt.id
  version = "$Latest"
}
  vpc_zone_identifier       = var.asg_subnet

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 200
  }

  # initial_lifecycle_hook {
  #   name                 = "foobar"
  #   default_result       = "CONTINUE"
  #   heartbeat_timeout    = 2000
  #   lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

  #   notification_metadata = jsonencode({
  #     foo = "bar"
  #   })

  #   notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
  #   role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  # }

  # tag {
  #   key                 = "foo"
  #   value               = "bar"
  #   propagate_at_launch = true
  # }

  # timeouts {
  #   delete = "15m"
  # }

  
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}

// now we create scaling policy for our asg for cpu utilizations.
resource "aws_autoscaling_policy" "cpu_target_tracking_policy" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_frontend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    disable_scale_in = false
  }

  cooldown = 500
}


// same metrics for memory utilization.
resource "aws_autoscaling_policy" "memory_target_tracking_policy" {
  name                   = "memory-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_frontend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageMemoryUtilization"
    }
    disable_scale_in = false
    
  }

  cooldown = 500

}

// now we create schedule scaling policy for our asg to scale out at 9 am and scale in at 6 pm.
resource "aws_autoscaling_schedule" "scale_out_schedule" {
  scheduled_action_name  = "scale-out-schedule"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_frontend_asg.name
  desired_capacity       = 2
  start_time             = "2024-07-01T09:00:00Z"
}

resource "aws_autoscaling_schedule" "scale_in_schedule" {
  scheduled_action_name  = "scale-in-schedule"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_frontend_asg.name
  desired_capacity       = 1
  start_time             = "2024-07-01T18:00:00Z"
}

