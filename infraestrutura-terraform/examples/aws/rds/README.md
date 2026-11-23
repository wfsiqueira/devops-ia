# Exemplo: RDS PostgreSQL em VPC dedicada

Cria a VPC (módulo `vpc`) e uma instância RDS PostgreSQL nas subnets privadas (módulo `rds`), com senha gerenciada pelo Secrets Manager e acesso liberado apenas a partir do CIDR da VPC.

O ambiente vem do workspace do Terraform: `default` → `dev`; qualquer outro workspace usa o próprio nome.

## Uso

```bash
cp backend.hcl.example backend.hcl   # edite bucket/key/region
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Para recuperar as credenciais do usuário master:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw master_user_secret_arn)" \
  --query SecretString --output text
```

## Notas

- Defaults deste exemplo são de **dev**: `deletion_protection = false`, `skip_final_snapshot = true`, `db.t4g.micro`, single-AZ. Em produção, inverta os dois primeiros e avalie `multi_az = true`.
- Em aplicações reais, prefira `allowed_security_group_ids` apontando para o SG da aplicação em vez de liberar o CIDR da VPC inteiro.
