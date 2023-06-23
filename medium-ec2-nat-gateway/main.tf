resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.network_tags
}

resource "aws_subnet" "private_subnet" {
  for_each                = var.private_subnet_cidr
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public_ip_on_launch
  tags = {
    "Name"  = "${each.value.scope}-${each.value.availability_zone}"
    "Scope" = each.value.scope
  }
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

resource "random_integer" "random_public_subnet" {
  min = 0
  max = length(var.public_subnet_cidr) - 1
}

resource "random_integer" "random_private_subnet" {
  min = 0
  max = length(var.private_subnet_cidr) - 1
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.network_tags
}


resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags       = var.network_tags
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = element(
  [for v in aws_subnet.public_subnet : v.id], random_integer.random_public_subnet.result)
  depends_on = [aws_internet_gateway.internet_gateway]
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
  for_each       = aws_subnet.public_subnet
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[each.key].id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Private-Route-table"
  }
}

resource "aws_route" "private_route_to_igw" {
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private_subnet
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[each.key].id
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "aws_ssh_key"
  public_key = tls_private_key.ssh_key_pair.public_key_openssh
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "ED25519"
  rsa_bits  = 4096
}

resource "local_file" "aws_ssh_private_key_file" {
  filename        = "id_ed25519.key"
  content         = tls_private_key.ssh_key_pair.private_key_openssh
  file_permission = "0600"
}

resource "aws_instance" "my_private_instance" {
  for_each                    = var.private_instance
  ami                         = each.value.ami
  instance_type               = each.value.type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = each.value.public_ip
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  subnet_id = element(
    [for v in aws_subnet.private_subnet : v.id], random_integer.random_private_subnet.result
  )
  lifecycle {
    replace_triggered_by = [aws_security_group.private_sg.id]
  }
  tags = { Name = "Private_Instance" }
}

resource "aws_security_group" "private_sg" {
  name        = "Private_Security_group"
  description = "Allow oubound traffic"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "private_any_egress_rule" {
  security_group_id = aws_security_group.private_sg.id
  description       = "any outbound"
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags              = var.network_tags
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_ingress_rule" {
  security_group_id = aws_security_group.private_sg.id
  description       = "ssh inbound"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = aws_vpc.vpc.cidr_block
  tags              = var.network_tags
}
