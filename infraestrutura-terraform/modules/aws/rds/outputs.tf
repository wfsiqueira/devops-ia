output "db_instance_id" {
  description = "Identificador da instância RDS."
  value       = aws_db_instance.this.identifier
}

output "db_instance_arn" {
  description = "ARN da instância RDS."
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "Endpoint de conexão no formato host:porta."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Hostname da instância RDS."
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Porta do banco."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco de dados inicial."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN do secret no Secrets Manager com as credenciais do usuário master."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "db_subnet_group_name" {
  description = "Nome do DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "security_group_id" {
  description = "ID do security group da instância RDS."
  value       = aws_security_group.this.id
}
