resource "aws_vpc" "workshop_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "workshop-vpc"
  }
}

resource "aws_internet_gateway" "workshop_gateway" {
  vpc_id = aws_vpc.workshop_vpc.id

  tags = {
    Name = "workshop-gateway"
  }
}

resource "aws_subnet" "workshop_subnet" {
  vpc_id = aws_vpc.workshop_vpc.id

  cidr_block        = "10.0.0.0/24"
  availability_zone = var.aws_zone

  tags = {
    Name = "workshop-subnet"
  }
}

resource "aws_route_table" "workshop_route_table" {
  vpc_id = aws_vpc.workshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.workshop_gateway.id
  }

  tags = {
    Name = "workshop_route_table"
  }
}

resource "aws_route_table_association" "workshop_route_table_association" {
  subnet_id      = aws_subnet.workshop_subnet.id
  route_table_id = aws_route_table.workshop_route_table.id
}

# Security group to allow all traffic
resource "aws_security_group" "workshop_sg_allowall" {
  name        = "workshop_sg_allowall"
  description = "Workshop - allow all traffic"
  vpc_id      = aws_vpc.workshop_vpc.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Creator = "Workshop Hacking Kubernetes"
  }
}