variable "project" {
  description = "Nome do projeto usado nas tags e nomes dos recursos."
  type        = string

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project não pode ser vazio."
  }
}

variable "environment" {
  description = "Ambiente associado aos recursos, por exemplo dev, staging ou prod."
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Sufixo do identificador da instância, por exemplo main ou orders."
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "name deve ser minúsculo, começar com letra e conter apenas letras, números e hífens."
  }
}

variable "vpc_id" {
  description = "ID da VPC onde o security group da instância será criado."
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets privadas do DB subnet group; mínimo de duas em AZs distintas."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Informe pelo menos duas subnets em AZs distintas."
  }
}

variable "allowed_security_group_ids" {
  description = "Security groups autorizados a conectar na porta do banco."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "Blocos CIDR autorizados a conectar na porta do banco."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_cidr_blocks : can(cidrnetmask(cidr))])
    error_message = "Todos os valores de allowed_cidr_blocks devem ser CIDRs IPv4 válidos."
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
  description = "Versão do engine, por exemplo 16.4; quando nula, a AWS usa a versão padrão."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Classe da instância RDS."
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "instance_class deve começar com db., por exemplo db.t4g.micro."
  }
}

variable "port" {
  description = "Porta do banco; quando nula, usa a porta padrão do engine."
  type        = number
  default     = null
}

variable "db_name" {
  description = "Nome do banco de dados inicial criado na instância."
  type        = string
  default     = "app"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "db_name deve começar com letra e conter apenas letras, números e underscore."
  }
}

variable "username" {
  description = "Usuário master; a senha é gerenciada pelo RDS via Secrets Manager."
  type        = string
  default     = "dbadmin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.username))
    error_message = "username deve começar com letra e conter apenas letras, números e underscore."
  }
}

variable "allocated_storage" {
  description = "Armazenamento inicial em GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage deve ser no mínimo 20 GiB."
  }
}

variable "max_allocated_storage" {
  description = "Limite do storage autoscaling em GiB; 0 desabilita."
  type        = number
  default     = 100

  validation {
    condition     = var.max_allocated_storage == 0 || var.max_allocated_storage >= 20
    error_message = "max_allocated_storage deve ser 0 (desabilitado) ou no mínimo 20 GiB."
  }
}

variable "kms_key_id" {
  description = "ARN da chave KMS para criptografia do storage; quando nula, usa a chave gerenciada pela AWS."
  type        = string
  default     = null
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

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "backup_retention_period deve estar entre 1 e 35 dias."
  }
}

variable "backup_window" {
  description = "Janela diária de backup em UTC, formato hh24:mi-hh24:mi."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Janela semanal de manutenção em UTC, formato ddd:hh24:mi-ddd:hh24:mi."
  type        = string
  default     = "sun:04:30-sun:05:30"
}

variable "deletion_protection" {
  description = "Impede a exclusão da instância; habilite em produção."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Pula o snapshot final na destruição; mantenha false em produção."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Habilita o Performance Insights."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Intervalo do enhanced monitoring em segundos; 0 desabilita."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval deve ser 0, 1, 5, 10, 15, 30 ou 60."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Logs exportados para o CloudWatch, conforme o engine; por exemplo [\"postgresql\"] ou [\"error\", \"slowquery\"]."
  type        = list(string)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Habilita autenticação IAM no banco."
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "Família do parameter group, por exemplo postgres16; obrigatória quando parameters não for vazio."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Parâmetros customizados do banco; quando vazio, usa o parameter group padrão do engine."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

variable "apply_immediately" {
  description = "Aplica modificações imediatamente em vez de aguardar a janela de manutenção."
  type        = bool
  default     = false
}
