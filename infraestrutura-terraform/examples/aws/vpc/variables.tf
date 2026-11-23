variable "aws_region" {
  description = "Região AWS onde a infraestrutura será provisionada."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region não pode ser vazio."
  }
}

variable "project" {
  description = "Nome do projeto usado nas tags e nos nomes dos recursos."
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

variable "availability_zones" {
  description = "AZs para as subnets; quando vazia, o módulo seleciona as AZs disponíveis."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || (length(var.availability_zones) >= 2 && length(distinct(var.availability_zones)) == length(var.availability_zones))
    error_message = "Informe zero ou pelo menos duas AZs distintas."
  }
}

variable "availability_zone_count" {
  description = "Quantidade de AZs quando availability_zones não for informada."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && floor(var.availability_zone_count) == var.availability_zone_count
    error_message = "availability_zone_count deve ser um número inteiro maior ou igual a 2."
  }
}

variable "subnet_newbits" {
  description = "Bits adicionados ao prefixo da VPC para determinar o tamanho das subnets."
  type        = number
  default     = 4

  validation {
    condition     = var.subnet_newbits >= 1 && var.subnet_newbits <= 8 && floor(var.subnet_newbits) == var.subnet_newbits
    error_message = "subnet_newbits deve ser um inteiro entre 1 e 8."
  }
}
