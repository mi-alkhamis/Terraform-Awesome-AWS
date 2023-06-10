resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
  tags       = var.network_tags
}

resource "aws_subnet" "subnet" {
  for_each          = var.subnet_cidr_block
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = var.network_tags
}
