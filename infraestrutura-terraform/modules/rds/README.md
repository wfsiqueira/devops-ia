# Módulo RDS

Instância RDS (PostgreSQL, MySQL ou MariaDB) com DB subnet group, security group dedicado e, opcionalmente, parameter group customizado e enhanced monitoring.

## Decisões de segurança

- `storage_encrypted = true` sempre; chave KMS própria opcional via `kms_key_id`.
- `publicly_accessible = false` fixo — acesso apenas via security groups ou CIDRs autorizados.
- Senha do usuário master gerenciada pelo RDS no **Secrets Manager** (`manage_master_user_password`); nenhuma senha passa pelo state ou pelo código. O ARN do secret é exposto em `master_user_secret_arn`.
- `deletion_protection = true` e snapshot final habilitados por padrão.

## Uso

```hcl
module "rds" {
  source = "../../modules/rds"

  project     = "devops-ia"
  environment = "dev"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = values(module.vpc.subnet_private_ids)

  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t4g.micro"

  allowed_security_group_ids = [aws_security_group.app.id]
}
```

Com parameter group customizado e enhanced monitoring:

```hcl
module "rds" {
  source = "../../modules/rds"

  project     = "devops-ia"
  environment = "prod"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = values(module.vpc.subnet_private_ids)

  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.r6g.large"
  multi_az               = true
  monitoring_interval    = 60
  parameter_group_family = "postgres16"

  parameters = [
    { name = "log_min_duration_statement", value = "500", apply_method = "immediate" },
  ]

  enabled_cloudwatch_logs_exports = ["postgresql"]
  allowed_security_group_ids      = [aws_security_group.app.id]
}
```

## Variáveis principais

| Nome | Default | Descrição |
|---|---|---|
| `project` | — | Nome do projeto (tags e nomes). |
| `environment` | `dev` | Ambiente (dev, staging, prod). |
| `name` | `main` | Sufixo do identificador. |
| `vpc_id` | — | VPC do security group. |
| `subnet_ids` | — | Subnets privadas (mínimo 2). |
| `allowed_security_group_ids` | `[]` | SGs com acesso ao banco. |
| `allowed_cidr_blocks` | `[]` | CIDRs com acesso ao banco. |
| `engine` | `postgres` | postgres, mysql ou mariadb. |
| `instance_class` | `db.t4g.micro` | Classe da instância. |
| `allocated_storage` | `20` | Storage inicial (GiB), gp3. |
| `max_allocated_storage` | `100` | Teto do autoscaling; 0 desabilita. |
| `multi_az` | `false` | Réplica síncrona em outra AZ. |
| `backup_retention_period` | `7` | Retenção de backups (dias). |
| `deletion_protection` | `true` | Proteção contra exclusão. |
| `skip_final_snapshot` | `false` | Snapshot final no destroy. |
| `monitoring_interval` | `0` | Enhanced monitoring (s); cria IAM role quando > 0. |

## Outputs

| Nome | Descrição |
|---|---|
| `db_instance_endpoint` | Endpoint `host:porta`. |
| `db_instance_address` | Hostname. |
| `db_instance_port` | Porta. |
| `master_user_secret_arn` | Secret com as credenciais master. |
| `security_group_id` | SG da instância. |
| `db_subnet_group_name` | DB subnet group. |
| `db_instance_id` / `db_instance_arn` / `db_name` | Identificação da instância. |
