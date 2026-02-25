// we setup a full ec2 instance with all the necessary resources and configurations using terraform. This includes security groups, key pairs, and user data scripts for initialization.

// first we create vpc.
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = local.vpc-tags
}

// now we create 4 subnets in different availability zones for high availability.
resource "aws_subnet" "ecommerce_public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = local.public-subnet-tags

  depends_on = [ aws_vpc.ecommerce_vpc ]
}

resource "aws_subnet" "ecommerce_private_subnet" {
  count = 2

  vpc_id            = aws_vpc.ecommerce_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 2)
  availability_zone = var.availability_zones[count.index]

  tags = local.private-subnet-tags

  depends_on = [ aws_vpc.ecommerce_vpc ]
}

// now we create an internet gateway and attach it to the vpc for internet connectivity.
resource "aws_internet_gateway" "ecommerce_igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id
  tags = local.igw-tags

  depends_on = [ aws_vpc.ecommerce_vpc ]
}

// now we create a route table and associate it with the public subnets for routing internet traffic.
resource "aws_route_table" "ecommerce_public_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce_igw.id
  }

  tags = local.public-route-table-tags
}

resource "aws_route_table" "ecommerce_private_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = local.private-route-table-tags
}


// now we associate the route tables with the respective subnets.
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.ecommerce_public_subnet[count.index].id
  route_table_id = aws_route_table.ecommerce_public_rt.id

  depends_on = [ aws_route_table.ecommerce_public_rt, aws_subnet.ecommerce_public_subnet ]
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.ecommerce_private_subnet[count.index].id
  route_table_id = aws_route_table.ecommerce_private_rt.id

  depends_on = [ aws_route_table.ecommerce_private_rt, aws_subnet.ecommerce_private_subnet ]
}


// now we create nat gateway in the public subnet for allowing outbound internet access from private subnets.
resource "aws_eip" "ecommerce_nat_eip" {
  tags = local.nat-eip-tags
}


resource "aws_nat_gateway" "ecommerce_nat_gateway" {
  allocation_id = aws_eip.ecommerce_nat_eip.id
  subnet_id     = aws_subnet.ecommerce_public_subnet[0].id

  tags = local.nat-gateway-tags

  depends_on = [ aws_eip.ecommerce_nat_eip, aws_subnet.ecommerce_private_subnet ]
  
}

// now we update the private route table to route internet traffic through the nat gateway.
resource "aws_route" "private_route_to_internet" {
  route_table_id         = aws_route_table.ecommerce_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ecommerce_nat_gateway.id
}

output "vpc_id" {
  value = aws_vpc.ecommerce_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.ecommerce_public_subnet.*.id
}

output "private_subnet_id" {
  value = aws_subnet.ecommerce_private_subnet.*.id
}