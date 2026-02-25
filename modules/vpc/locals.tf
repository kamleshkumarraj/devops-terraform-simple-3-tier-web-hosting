locals {
  common-tags = {
    owner       = "devops-admin"
    environment = "development"
  }

  public-subnet-tags = merge(local.common-tags, {
    name = "public-subnet"
  })

  private-subnet-tags = merge(local.common-tags, {
    name = "private-subnet"
  })

  igw-tags = merge(local.common-tags, {
    name = "ecommerce-igw"
  })

  vpc-tags = merge(local.common-tags, {
    name = "ecommerce-vpc"
  })

  public-route-table-tags = merge(local.common-tags, {
    name = "public-route-table"
  })

  private-route-table-tags = merge(local.common-tags, {
    name = "private-route-table"
  })

  nat-eip-tags = merge(local.common-tags, {
    name = "ecommerce-nat-eip"
  })

  nat-gateway-tags = merge(local.common-tags, {
    name = "ecommerce-nat-gateway"
  })

}
