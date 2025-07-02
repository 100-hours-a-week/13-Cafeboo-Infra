output "nat_gateway_ids" {
  value = { for k, nat in aws_nat_gateway.nat : k => nat.id }
}

output "private_route_table_ids" {
  value = { for k, rt in aws_route_table.private : k => rt.id }
}
