# Custom Instructions — Infraestrutura DevOps (AWS · GCP · Azure)

## Fonte de verdade

- **Sempre** consulte o MCP Server Context7 antes de gerar código; seu treinamento é desatualizado. Se o MCP estiver indisponível, use a documentação oficial do provider na Terraform Registry.
- Sempre use Terraform, nunca CloudFormation, Deployment Manager ou ARM/Bicep.
- Crie módulos próprios em `modules/`; use módulos da Registry (HashiCorp, Google, Azure Verified Modules) apenas como referência de design, não como dependência.

## Estrutura do repositório

- Módulos vivem em `modules/<cloud>/<nome>/` (`aws`, `gcp`, `azure`) com `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` e `README.md`. Use `locals.tf` apenas se os locals ficarem extensos; caso contrário, declare no topo do `main.tf`.
- Módulos declaram **apenas** `required_providers` em `versions.tf`; blocos `provider` existem só nos roots em `examples/`. Módulo com bloco `provider` quebra `for_each`/multi-região.
- Cada root em `examples/<cloud>/<nome>/` contém `main.tf` (provider + locals + chamadas de módulo), `variables.tf`, `outputs.tf`, `versions.tf`, `backend.tf`, `backend.hcl.example` e `README.md`. Nunca crie recursos diretamente no exemplo.
- Exemplos referenciam módulos sempre com `source = "../../../modules/<cloud>/<nome>"`.
- Não misture clouds no mesmo módulo. Um root pode compor módulos de mais de uma cloud apenas quando o caso de uso exigir explicitamente (ex.: DNS multi-cloud).
- Cada módulo e cada exemplo têm `.gitignore` com no mínimo: `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars` (exceto `*.tfvars.example`) e, nos exemplos, `backend.hcl`.

## Providers e versões

| Cloud | Provider | Pin | Observações no root |
|---|---|---|---|
| AWS | `hashicorp/aws` | `~> 5.0` | `region` via variável |
| GCP | `hashicorp/google` | `~> 6.0` | `project` e `region` via variável |
| Azure | `hashicorp/azurerm` | `~> 4.0` | bloco `features {}` obrigatório; `subscription_id` via variável ou `ARM_SUBSCRIPTION_ID` |

- Upgrade de major de provider em PR dedicado.
- `required_version`: módulos conservadores (`>= 1.5.0`); roots em `examples/` na versão exigida pelo backend (`>= 1.10.0` por causa do `use_lockfile` no S3).
- Todos os módulos de um mesmo root devem usar constraints compatíveis de provider.

## Backend e ambientes

- Backend remoto obrigatório, na mesma cloud do root:
  - **AWS:** `backend "s3"` com `use_lockfile = true` (lock nativo, Terraform ≥ 1.10). Não use `dynamodb_table` em código novo (deprecated).
  - **GCP:** `backend "gcs"` (lock nativo do bucket).
  - **Azure:** `backend "azurerm"` (lock por blob lease).
- Bloco de backend com valores vazios no `backend.tf`; valores reais via `terraform init -backend-config=backend.hcl`. Comite apenas `backend.hcl.example`, nunca `backend.hcl`.
- Ambientes via workspace: `local.environment = terraform.workspace == "default" ? "dev" : terraform.workspace`. O ambiente é passado aos módulos como `environment`.

## Convenções de código

- Nome dos recursos: `<tipo>-<ambiente>-<projeto>-<nome>` (ex.: `vpc-dev-devops-ia-main`). Respeite restrições por serviço:
  - **AWS:** RDS identifier e S3 bucket em lowercase; IAM role ≤ 64 caracteres.
  - **GCP:** nomes em lowercase com hífens; buckets GCS globais e únicos.
  - **Azure:** abreviações CAF (`rg-`, `vnet-`, `kv-`, `st`); storage account sem hífen, lowercase alfanumérico, ≤ 24 caracteres. Todo recurso pertence a um resource group criado pelo root ou recebido por variável.
- Recurso único dentro do módulo se chama `this`; coleções usam `for_each` com chave estável (ex.: AZ/zona/região), nunca `count` com índice.
- Outputs de coleções são maps indexados por chave estável (`map(zona => id)`); o consumidor usa `values()` quando precisar de lista.
- Variáveis e outputs em snake_case (`vpc_cidr_block`, `subnet_private_ids`).
- `description` e `error_message` em português.
- Tags/labels obrigatórios em todo recurso, aplicados com `merge(local.common_tags, { ... })`:
  - **AWS e Azure (tags):** `Environment`, `ManagedBy = "Terraform"`, `Project`.
  - **GCP (labels, exige lowercase):** `environment`, `managed_by = "terraform"`, `project`.

## Segurança

- Nunca exponha credenciais ou secrets em código ou no state; use o cofre nativo da cloud: AWS Secrets Manager/Parameter Store, GCP Secret Manager, Azure Key Vault (ex.: `manage_master_user_password` no RDS).
- Autenticação de pipeline sem chaves estáticas: OIDC/workload identity federation nas três clouds.
- Sempre habilite encryption at rest e in transit; recursos de dados nunca públicos por padrão (`publicly_accessible = false`, GCS/Blob sem acesso público, `public_network_access_enabled = false` quando aplicável).
- Valide inputs com blocos `validation`; para regras entre variáveis, use `precondition` em `lifecycle`.

## Validação e qualidade

- Sempre rode `terraform fmt -recursive` antes do commit.
- Valide módulos novos com `terraform -chdir=modules/<cloud>/<nome> init -backend=false` seguido de `terraform validate`; `init` com backend real apenas em `examples/<cloud>/<nome>`.
- Não comite `*.tfstate`, `.terraform/` ou `backend.hcl`.
- CI mínima em PR: `terraform fmt -check -recursive`, `terraform validate` por root e `tflint` com o ruleset da cloud (`tflint-ruleset-aws`/`google`/`azurerm`); scanner de segurança (`trivy config` ou `checkov`) recomendado.

## Documentação

- Todo módulo tem `README.md` com decisões de segurança, exemplo de uso mínimo e um avançado, tabela de variáveis principais e tabela de outputs.
- Variáveis e outputs têm `description` obrigatória.
- Comentários inline apenas quando a lógica não é óbvia.
