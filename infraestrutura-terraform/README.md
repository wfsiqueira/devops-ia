# Infraestrutura Terraform

A raiz chama o módulo local `modules/vpc`. O ambiente usado na tag `Environment` corresponde ao workspace selecionado; o workspace padrão `default` usa `dev`.

## Requisitos

- Terraform 1.10 ou superior
- AWS provider `~> 5.0`
- Credenciais AWS disponíveis pelo provider chain padrão
- Bucket S3 pré-criado para o state, com versionamento e criptografia habilitados
- Tabela DynamoDB pré-criada com partition key `LockID` do tipo `String`

O backend usa o lockfile S3 (`use_lockfile`) e configura também DynamoDB para compatibilidade com a convenção do projeto. O locking via DynamoDB está deprecated pelo Terraform; planeje remover `dynamodb_table` após migrar consumidores antigos para o locking nativo do S3.

## Inicialização e uso

1. Copie `backend.hcl.example` para `backend.hcl` e substitua bucket, região e tabela pelos recursos do seu ambiente. `backend.hcl` é ignorado pelo Git.
2. Inicialize o backend:

   ```sh
   terraform init -backend-config=backend.hcl
   ```

3. Crie ou selecione um workspace (`dev`, `staging` ou `prod`):

   ```sh
   terraform workspace new dev
   ```

   Para um workspace existente, use `terraform workspace select dev`.

4. Revise e aplique:

   ```sh
   terraform plan
   terraform apply
   ```

O módulo seleciona duas AZs disponíveis por padrão e cria um NAT Gateway em cada AZ. Os NAT Gateways geram custos por hora e pelo tráfego processado.

## Configuração da VPC

Edite os valores padrão em `variables.tf` ou passe `-var`/um arquivo `.tfvars` local para `aws_region`, `project`, `vpc_cidr_block`, `availability_zones`, `availability_zone_count` e `subnet_newbits`. Arquivos `.tfvars` são ignorados pelo Git.

As saídas da raiz incluem `vpc_id`, `subnet_public_ids`, `subnet_private_ids` e `nat_gateway_ids`.
