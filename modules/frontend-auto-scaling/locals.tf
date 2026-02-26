locals {
  commonTags = var.common_tags
  ft_launch_template_tags = merge(
    local.commonTags,
    {
      "name" = "${var.frontend_lt_name}"
    }
  )
}
