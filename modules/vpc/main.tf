
# VPC

resource "aws_vpc" "ecommerce_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc-tags
}

# INTERNET GATEWAY

resource "aws_internet_gateway" "ecommerce_igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = local.igw-tags
}

# PUBLIC SUBNETS (1 PER AZ)

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = local.public-subnet-tags
}

# PRIVATE SUBNETS (1 PER AZ)

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.ecommerce_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 2)
  availability_zone = var.availability_zones[count.index]

  tags = local.private-subnet-tags
}

# PUBLIC ROUTE TABLE

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = local.public-route-table-tags
}

# Internet Route
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecommerce_igw.id
}

# Associate Public Subnets
resource "aws_route_table_association" "public_assoc" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ELASTIC IPs FOR NAT (1 PER AZ)

resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = local.nat-eip-tags
}

# NAT GATEWAY (1 PER AZ)

resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = local.nat-gateway-tags
}

# PRIVATE ROUTE TABLES (1 PER AZ)

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = local.private-route-table-tags
}

# Route private traffic via NAT in same AZ
resource "aws_route" "private_nat" {
  count = length(var.availability_zones)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

# Associate Private Subnets
resource "aws_route_table_association" "private_assoc" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

output "vpc_id" {
  value = aws_vpc.ecommerce_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "private_subnet_id" {
  value = aws_subnet.private.*.id
}