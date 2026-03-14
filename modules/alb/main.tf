// sg for public facing load balancer to allow traffic only on port 80 for HTTP and 443 for HTTPS from internet.
resource "aws_security_group" "public_alb_sg" {
  name        = "public_alb_sg"
  description = "Security group for Ecommerce Public ALB"
  vpc_id      = var.vpc_id

  # Allow HTTP from Internet
  dynamic "ingress" {
    for_each = local.frontend_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.frontend_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      
    }
  }

  tags = local.public_alb_sg_tags
}

// now we define sg for internal load balancer to allow traffic only from frontend server security group on port 4000 for API.
# resource "aws_security_group" "internal_alb_sg" {
#   name        = "internal_alb_sg"
#   description = "Security group for Ecommerce Internal ALB"
#   vpc_id      = var.vpc_id

#   # Allow traffic from frontend ALB security group on port 4000
#   dynamic "ingress" {
#     for_each = local.backend_ingress_rules
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks  = ingress.value.cidr_blocks
#     }
#   }

#   dynamic "egress" {
#     for_each = local.backend_egress_rules
#     content {
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       protocol    = egress.value.protocol
#       cidr_blocks = egress.value.cidr_blocks
#     }
#   }

#   tags = local.internal_alb_sg_tags
# }

// jenkins serevr getting via data source.
data "aws_instance" "jenkins-server" {
  
  filter {
    name   = "tag:server"
    values = ["jenkins"]
  }
}
  
// this load balancer is public internet facing only for frontend server.
resource "aws_lb" "frontend_public_alb" {
  name               = "frontend-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = [for subnet in var.alb_public_subnet: subnet]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = local.alb_tags
}


resource "aws_lb_listener" "frontend_listener_http" {
  load_balancer_arn = aws_lb.frontend_public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  target_health_state {
    enable_unhealthy_connection_termination = false
  }
}

# resource "aws_lb_listener_rule" "frontend_rule" {
#   listener_arn = aws_lb_listener.frontend_listener_http.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend_tg.arn
#   }

#   condition {
#     host_header {
#       values = ["ecommerce.viharfood.in"]
#     }
#   }
# }

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_health_state {
    enable_unhealthy_connection_termination = false
  }
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/api/v2/health-check"

  }
}

# resource "aws_lb_listener_rule" "backend_rule" {
#   listener_arn = aws_lb_listener.frontend_listener_http.arn
#   priority     = 101

#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#   }
#   condition {
#     host_header {
#       values = ["api.ecommerce.viharfood.in"]
#     }
#   }
#   depends_on = [ aws_lb_target_group.backend_tg ]
# }

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  target_health_state {
    enable_unhealthy_connection_termination = false
  }
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/"
    matcher = "200,301,302"
    
  }
  
}

resource "aws_lb_target_group_attachment" "jenkins_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = data.aws_instance.jenkins-server.id   # 👈 specific instance
  port             = 8080
}

# resource "aws_lb_listener_rule" "jenkins_rule" {
#   listener_arn = aws_lb_listener.frontend_listener_http.arn
#   priority     = 102

#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.jenkins_tg.arn
#   }
  
#   condition {
#     host_header {
#       values = ["jenkins.viharfood.in"]
#     }
#   }
#   depends_on = [ aws_lb_target_group.jenkins_tg ]
# }



// ========================================Backend ALB and Target Group for API Server=========================

// now we create private internael load balancer for backend server to allow traffic only from frontend server security group on port 8000 for API.
# resource "aws_lb" "backend_internal_alb" {
#   name               = "backend-internal-alb"
#   internal           = true
#   load_balancer_type = "application"

#   subnets = [for subnet in var.alb_private_subnet: subnet]
#   security_groups    = [aws_security_group.internal_alb_sg.id]
# }

// now we create tg for backend server to allow traffic only from frontend server security group on port 8000 for API.




# resource "aws_lb_listener" "backend_listener_http" {
#   load_balancer_arn = aws_lb.backend_internal_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#   }
# }

// now we create listener rule for backend server to allow traffic only from frontend server security group on port 8000 for API.



output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "ecommerce_alb_dns" {
  value = aws_lb.frontend_public_alb.dns_name
}

output "ecommerce_alb_zone_id" {
  value = aws_lb.frontend_public_alb.zone_id
}

// now we create certificate and then we will create listener for HTTPS on port 443 for frontend server and then we will create listener rule for HTTPS on port 443 for frontend server.

resource "aws_acm_certificate" "https_cert" {
  domain_name       = var.domain_name
  subject_alternative_names = ["*.viharfood.in", "api.ecommerce.viharfood.in"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "alb-https-cert"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.https_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = var.zone_id
  records         = [each.value.value]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {

  certificate_arn = aws_acm_certificate.https_cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

resource "aws_lb_listener" "https_listener" {

  load_balancer_arn = aws_lb.frontend_public_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  tags = {
    Name = "production-https-listener"
  }
}


resource "aws_lb_listener_rule" "frontend_rule_https" {
  listener_arn = aws_lb_listener.https_listener.arn
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
}

resource "aws_lb_listener_rule" "backend_rule_https" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 101

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
  condition {
    host_header {
      values = ["api.ecommerce.viharfood.in"]
    }
  }
  depends_on = [ aws_lb_target_group.backend_tg ]
}

resource "aws_lb_listener_rule" "jenkins_rule_https" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 102

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
  
  condition {
    host_header {
      values = ["jenkins.viharfood.in"]
    }
  }
  depends_on = [ aws_lb_target_group.jenkins_tg ]
}

# resource "aws_lb_listener" "http_to_https_redirect" {

#   load_balancer_arn = aws_lb.frontend_public_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }