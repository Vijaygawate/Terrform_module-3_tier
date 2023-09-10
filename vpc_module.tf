# Author    : Vijay Gawte (DevOps)
# GitHub    : https://github.com/Vijaygawate
########################################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "CustomVPC"
  }
}

# Author    : Vijay Gawte
# GitHub    : https://github.com/Vijaygawate
########################################################

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr[count.index]
  availability_zone = var.az[count.index]
  count = 2

  tags = {
    Name = "public-sub"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-sub3"
  }
}

data "aws_subnets" "sid" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  tags = {
    Tier = "Public"
  }
}

# Author    : Vijay Gawte
# GitHub    : https://github.com/Vijaygawate
########################################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# Author    : Vijay Gawte
# GitHub    : https://github.com/Vijaygawate
########################################################

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# Author    : Vijay Gawte
# GitHub    : https://github.com/Vijaygawate
########################################################

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "MyRoute"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rtb.id
  count = 2
}
/*
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtb.id
}
*/
//Adding NAT Gateway into the default main route table
resource "aws_default_route_table" "dfltrtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "dfltrtb"
  }
}
/*
  


# Author    : Ranjit Kumar Swain
# Web       : www.ranjitswain.com
# YouTube   : https://www.youtube.com/c/ranjitswain
# GitHub    : https://github.com/ranjit4github
########################################################
/*
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {  //Ephemeral Port
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "main"
  }
}

resource "aws_network_acl_association" "main" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.public.id
}

*/
  
