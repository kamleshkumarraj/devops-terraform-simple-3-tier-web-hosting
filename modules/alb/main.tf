resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  ingress = [ {
    from_port = 0
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "http"
  } ]

  egress = [ {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "http"
  } ]
}

resource "aws_lb" "ecommerce_alb" {
  name               = "ecommerce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in var.alb_subnet: subnet]

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = local.alb_tags
  depends_on = [ aws_security_group.alb_sg ]
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_health_state {
    enable_unhealthy_connection_termination = false
  }
}

// now we create tg for backend server to allow traffic only from frontend server security group on port 8000 for API.
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 8000
  protocol = "TCP"
  vpc_id   = var.vpc_id

  target_health_state {
    enable_unhealthy_connection_termination = false
  }
}


resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  

  condition {
    host_header {
      values = ["ecommerce.viharfood.in"]
    }
  }
  depends_on = [ aws_lb_target_group.frontend_tg ]
}

// now we create listener rule for backend server to allow traffic only from frontend server security group on port 8000 for API.
resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
  condition {
    host_header {
      values = ["ecommerce-api.viharfood.in"]
    }
  }
  depends_on = [ aws_lb_target_group.backend_tg ]
}


output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}