variable "aws_region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nome do projeto usado nas tags e nomes dos recursos."
  type        = string
  default     = "devops-ia"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project não pode ser vazio."
  }
}

variable "vpc_cidr_block" {
  description = "Bloco CIDR IPv4 da VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(regex("/(1[6-9]|2[0-8])$", var.vpc_cidr_block)) && can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block deve ser um bloco CIDR IPv4 válido entre /16 e /28."
  }
}

variable "availability_zone_count" {
  description = "Quantidade de AZs usadas pela VPC."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && floor(var.availability_zone_count) == var.availability_zone_count
    error_message = "availability_zone_count deve ser um número inteiro maior ou igual a 2."
  }
}

variable "engine" {
  description = "Engine do banco: postgres, mysql ou mariadb."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "engine deve ser postgres, mysql ou mariadb."
  }
}

variable "engine_version" {
  description = "Versão do engine; quando nula, a AWS usa a versão padrão."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Classe da instância RDS."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nome do banco de dados inicial."
  type        = string
  default     = "app"
}

variable "multi_az" {
  description = "Habilita réplica síncrona em outra AZ."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Dias de retenção dos backups automáticos."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Impede a exclusão da instância; habilite em produção."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Pula o snapshot final na destruição; mantenha false em produção."
  type        = bool
  default     = true
}
