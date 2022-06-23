output vpc_id {
    description = "Vpc id"
    value       = aws_vpc.vpc-net.id
}

output "vpc_main_rt" {
  value       = aws_vpc.vpc-net.default_route_table_id
  description = "Vpc main route table"
}

output vpc_private_subnets {
  value       = aws_subnet.private-subnet.*.id
  description = "List of private networks genereted"
}


output vpc_public_subnets {
  value       = aws_subnet.public-subnet.*.id
  description = "List of public networks genereted"
}