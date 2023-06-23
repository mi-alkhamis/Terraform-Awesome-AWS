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
  for_each       = aws_subnet.public_subnet
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[each.key].id
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

resource "random_integer" "random_public_subnet" {
  min = 0
  max = length(var.public_subnet_cidr) - 1
}

resource "aws_instance" "my_public_instance" {
  for_each                    = var.public_instance
  ami                         = each.value.ami
  instance_type               = each.value.type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = each.value.public_ip
  vpc_security_group_ids      = [aws_security_group.EC2_security_group.id]
  subnet_id = element(
  [for v in aws_subnet.public_subnet : v.id], random_integer.random_public_subnet.result)
  tags = {
    Name = "My_Public_Instance"
  }
}

resource "aws_security_group" "EC2_security_group" {
  name        = "allow_tls"
  description = "Allow SSH,ICMP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH,"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self        = "true"
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
    self        = "true"
  }
  egress {
    description = "Any outbound"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    self        = "true"

  }
  tags = var.network_tags
}
