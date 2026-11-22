output "vpc_id" {
  description = "ID da VPC criada."
  value       = aws_vpc.this.id
}

output "subnet_public_ids" {
  description = "IDs das subnets públicas, indexados por AZ."
  value       = { for availability_zone, subnet in aws_subnet.public : availability_zone => subnet.id }
}

output "subnet_private_ids" {
  description = "IDs das subnets privadas, indexados por AZ."
  value       = { for availability_zone, subnet in aws_subnet.private : availability_zone => subnet.id }
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways, indexados por AZ."
  value       = { for availability_zone, nat_gateway in aws_nat_gateway.this : availability_zone => nat_gateway.id }
}
