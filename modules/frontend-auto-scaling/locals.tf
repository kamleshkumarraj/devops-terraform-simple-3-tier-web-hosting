locals {
  commonTags = var.common_tags
  ft_launch_template_tags = merge(
    local.commonTags,
    {
      "name" = "${var.frontend_lt_name}"
    }
  )

  ft_asg_tsg = merge(
    local.commonTags,
    {
      "name" = "${var.asg_name}"
    }
  )

  frontend_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-frontend-server-sg"
  })
}
