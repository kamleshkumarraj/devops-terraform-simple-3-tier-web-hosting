locals {
  common-tags = {
    owner       = "devops-admin"
    environment = "development"
  }

  public-subnet-tags = merge(local.common-tags, {
    Name = "public-subnet"
  })

  private-subnet-tags = merge(local.common-tags, {
    Name = "private-subnet"
  })

  igw-tags = merge(local.common-tags, {
    Name = "ecommerce-igw"
  })

  vpc-tags = merge(local.common-tags, {
    Name = "ecommerce-vpc"
  })

  public-route-table-tags = merge(local.common-tags, {
    Name = "public-route-table"
  })

  private-route-table-tags = merge(local.common-tags, {
    Name = "private-route-table"
  })

  nat-eip-tags = merge(local.common-tags, {
    Name = "ecommerce-nat-eip"
  })

  nat-gateway-tags = merge(local.common-tags, {
    Name = "ecommerce-nat-gateway"
  })

}
