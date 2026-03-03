locals {
  common_tags = var.common_tags

  hosted_zone_tags = merge(var.common_tags, {
    Name: "ecommerce-hosted-zones"
  })
}

