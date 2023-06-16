
resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.network_tags
}

resource "aws_subnet" "public_subnet" {
  for_each                = var.public_subnet_cidr
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public_ip_on_launch
  tags = {
    "Name"  = "${each.value.scope}-${each.value.availability_zone}"
    "Scope" = each.value.scope
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.network_tags
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Public-Route-table"
  }
}


resource "aws_route" "public_route_to_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}



resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnet_cidr)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = element(
    [
      for v in aws_subnet.public_subnet : v.id
  ], count.index)
}