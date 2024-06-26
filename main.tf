

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "ngw" {
  count           = 3
  allocation_id   = aws_eip.nat[count.index].id
  subnet_id       = aws_subnet.private[count.index].id
}

resource "aws_eip" "nat" {
  count = 3
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = 3
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  count               = 3
  route_table_id      = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
   nat_gateway_id      = aws_nat_gateway.ngw[count.index].id
}
