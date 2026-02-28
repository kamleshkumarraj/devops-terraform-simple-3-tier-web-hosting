locals {
  commonTags = var.common_tags

  db_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-db-server-sg"
  })

}