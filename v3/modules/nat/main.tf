resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"

  tags = {
    Name = "nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "nat-gw-${each.key}"
  }

  depends_on = [aws_eip.nat]
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets
  vpc_id   = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = {
    Name = "private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.private_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}
