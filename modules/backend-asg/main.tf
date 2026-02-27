// we create first launch template.

resource "aws_launch_template" "ecommerce_backend_lt" {
  name = var.backend_lt_name

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
    name = var.backend_ecr_s3_access_role
  }

  image_id = var.backend_lt_ami_id

  instance_initiated_shutdown_behavior = "terminate"

  # instance_market_options {
  #   market_type = "capacity-block"
  # }

  instance_type = var.backend_lt_instance_type

  # kernel_id = "test"

  key_name = var.backend_lt_key_name


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

  vpc_security_group_ids = [var.backend_sg]

  tag_specifications {
    resource_type = "instance"

    tags = local.ft_launch_template_tags
  }

  user_data = filebase64("${path.module}/application_setup.sh")
}

// now we cretae auto scaling group for backend.

# resource "aws_placement_group" "backend_asg_placement_group" {
#   name     = "backend-asg-placement-group"
#   strategy = "cluster"
# }



resource "aws_autoscaling_group" "ecommerce_backend_asg" {
  name                      = var.asg_name
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_gp
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete              = true
  # placement_group           = aws_placement_group.backend_asg_placement_group.id
  launch_template {
  id      = aws_launch_template.ecommerce_backend_lt.id
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

  target_group_arns = [
    var.backend_tg_arn
  ]

  
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}

// now we create scaling policy for our asg for cpu utilizations.
resource "aws_autoscaling_policy" "cpu_target_tracking_policy" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_backend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    disable_scale_in = false
  }

  # cooldown = 500
}

resource "aws_autoscaling_policy" "memory_target_tracking_policy" {
  name                   = "memory-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_backend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70

    customized_metric_specification {
      metric_name = "mem_used_percent"
      namespace   = "CWAgent"
      statistic   = "Average"
      unit        = "Percent"

      # dimensions {
      #   name  = "AutoScalingGroupName"
      #   value = aws_autoscaling_group.ecommerce_backend_asg.name
      # }
    }

    disable_scale_in = false
  }

  
}


// now we create schedule scaling policy for our asg to scale out at 9 am and scale in at 6 pm.
resource "aws_autoscaling_schedule" "weekday_scale_out" {
  scheduled_action_name  = "weekday-scale-out"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_backend_asg.name

  min_size         = 1
  max_size         = 5
  desired_capacity = 1

  recurrence = "0 8 * * MON-FRI"

  start_time = var.scale_out_start_time

  time_zone = "Asia/Kolkata"
}

resource "aws_autoscaling_schedule" "weekday_scale_in" {
  scheduled_action_name  = "weekday-scale-in"
  autoscaling_group_name = aws_autoscaling_group.ecommerce_backend_asg.name

  min_size         = 0
  max_size         = 0
  desired_capacity = 0

  recurrence = "0 20 * * MON-FRI"

  start_time = var.scale_in_start_time

  time_zone = "Asia/Kolkata"
}
