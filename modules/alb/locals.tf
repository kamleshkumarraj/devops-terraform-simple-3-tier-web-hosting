locals {
  common_tags = var.common_tags

  alb_tags = merge(local.common_tags, {
    name = "ecommerce-alb"
  })

  public_alb_sg_tags = merge(local.common_tags, {
    name = "ecommerce-frontend-alb-sg"
  })

  internal_alb_sg_tags = merge(local.common_tags, {
    name = "ecommerce-internal-alb-sg"
  })
  frontend_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  frontend_egress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}