output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

output "db_instance_endpoint" {
  description = "Endpoint de conexão no formato host:porta."
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "Hostname da instância RDS."
  value       = module.rds.db_instance_address
}

output "db_instance_port" {
  description = "Porta do banco."
  value       = module.rds.db_instance_port
}

output "master_user_secret_arn" {
  description = "ARN do secret no Secrets Manager com as credenciais do usuário master."
  value       = module.rds.master_user_secret_arn
}

output "security_group_id" {
  description = "ID do security group da instância RDS."
  value       = module.rds.security_group_id
}
