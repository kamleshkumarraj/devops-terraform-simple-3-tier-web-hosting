locals {
  commonTags = var.common_tags

  frontend_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-frontend-server-sg"
  })

  backend_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-backend-server-sg"
  })

  db_server_sg_tags = merge(local.commonTags, {
    name = "ecommerce-db-server-sg"
  })

}