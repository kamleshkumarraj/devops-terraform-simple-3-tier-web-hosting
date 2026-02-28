locals {
  commonTags = var.common_tags
  backend_launch_template_tags = merge(
    local.commonTags,
    {
      "name" = "${var.backend_lt_name}"
    }
  )

  backend_asg_tags = merge(
    local.commonTags,
    {
      "name" = "${var.asg_name}"
    }
  )

  backend_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-backend-server-sg"
  })
}
