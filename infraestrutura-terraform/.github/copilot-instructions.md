# Custom Instructions — Infraestrutura DevOps

## Padrões de Infraestrutura como Código

- **Sempre** use o Mcp Server Context7, seu treinamento é desatualizado, então siga as instruções abaixo.
- **Sempre** crie os módulos de terraform dentro da pasta `modules/` e use `main.tf`, `variables.tf`, `outputs.tf` como padrão.
- **Sempre** use `locals.tf` para variáveis locais e `providers.tf` para configuração de providers.
- **Sempre** sempre crie o `.gitignore` dentro do módulo, mesmo que seja vazio, para evitar que arquivos de estado sejam comitados.
- Use o `main.tf`da raiz do projeto para chamar os módulos, não crie recursos diretamente nele.
- Sempre use Terraform, nunca CloudFormation ou ARM templates
- Prefira módulos oficiais da HashiCorp Registry
- Use versioning explícito para providers (ex: `version = "~> 5.0"`)
- Sempre inclua tags obrigatórias: `Environment`, `ManagedBy`, `Project`

## Convenções de Nomenclatura

- Recursos AWS: formato `<tipo>-<ambiente>-<projeto>-<nome>`
- Variáveis: snake_case (ex: `vpc_cidr_block`)
- Outputs: snake_case descritivos (ex: `vpc_id`, `subnet_private_ids`)

## Segurança

- Nunca exponha credenciais ou secrets em código
- Use AWS Secrets Manager ou Parameter Store para dados sensíveis
- Sempre habilite encryption at rest e in transit
- Valide inputs com `validation` blocks nas variáveis

## Documentação

- Todo módulo deve ter um README.md com exemplos
- Variáveis devem ter `description` obrigatória
- Outputs devem ter `description` explicativa
- Inclua comentários inline apenas quando a lógica não é óbvia

## Boas Práticas DevOps

- Use workspaces do Terraform para múltiplos ambientes
- Backend remoto obrigatório (S3 + DynamoDB para lock)
- Sempre rode `terraform fmt` antes do commit
- Use `terraform validate` para checar sintaxe e consistência
- Não comite arquivos de estado (`*.tfstate`) ou diretórios `.terraform/` no repositório
- Não execute `terraform init` quando criando um novo módulo, apenas rode `terraform init` na raiz do projeto
- Inclua `.terraform/` e `*.tfstate` no `.gitignore`
