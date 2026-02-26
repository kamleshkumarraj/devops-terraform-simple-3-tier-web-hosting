locals {
  common_tags = var.common_tags

  alb_tags = merge(local.common_tags, {
    name = "ecommerce-alb"
  })
}