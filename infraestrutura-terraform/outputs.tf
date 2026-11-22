output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

output "subnet_public_ids" {
  description = "IDs das subnets públicas, indexados por AZ."
  value       = module.vpc.subnet_public_ids
}

output "subnet_private_ids" {
  description = "IDs das subnets privadas, indexados por AZ."
  value       = module.vpc.subnet_private_ids
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways, indexados por AZ."
  value       = module.vpc.nat_gateway_ids
}
