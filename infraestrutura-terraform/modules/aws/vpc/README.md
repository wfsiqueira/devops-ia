# Módulo VPC AWS

Provisiona uma VPC com subnets públicas e privadas em pelo menos duas zonas de disponibilidade (AZs). Cada AZ tem seu próprio NAT Gateway para fornecer saída à internet às subnets privadas. Os NAT Gateways geram custos por hora e pelo tráfego processado.

## Recursos criados

- `aws_vpc` — VPC com suporte e nomes DNS habilitados.
- `aws_internet_gateway` — acesso à internet para as subnets públicas.
- `aws_subnet` — uma subnet pública e uma privada por AZ.
- `aws_route_table` — tabela pública compartilhada e uma tabela privada por AZ.
- `aws_route` — rotas públicas para o Internet Gateway e rotas privadas para o NAT Gateway da mesma AZ.
- `aws_route_table_association` — associa as subnets às respectivas tabelas de rotas.
- `aws_eip` — endereço IP elástico para cada NAT Gateway.
- `aws_nat_gateway` — um NAT Gateway público em cada subnet pública.

O data source `aws_availability_zones` fornece as AZs disponíveis quando `availability_zones` não é especificada.

## Variáveis

| Nome | Tipo | Descrição | Padrão |
| --- | --- | --- | --- |
| `vpc_cidr_block` | `string` | Bloco CIDR IPv4 da VPC. Deve estar entre `/16` e `/28`. | `10.0.0.0/16` |
| `availability_zones` | `list(string)` | AZs para as subnets; quando vazia, o módulo seleciona as primeiras AZs disponíveis. | `[]` |
| `availability_zone_count` | `number` | Quantidade de AZs quando `availability_zones` não for informada. | `2` |
| `subnet_newbits` | `number` | Bits adicionados ao prefixo da VPC para determinar o tamanho das subnets. | `4` |
| `environment` | `string` | Ambiente associado aos recursos e à tag `Environment`. | `dev` |
| `project` | `string` | Nome do projeto usado nas tags e nos nomes dos recursos. | Obrigatório |

Com os valores padrão, cada subnet usa um bloco `/20`. O módulo exige pelo menos duas AZs e atribui as tags `Environment`, `ManagedBy` e `Project` aos recursos compatíveis.

## Outputs

| Nome | Descrição |
| --- | --- |
| `vpc_id` | ID da VPC criada. |
| `subnet_public_ids` | Mapa de IDs das subnets públicas, indexado por AZ. |
| `subnet_private_ids` | Mapa de IDs das subnets privadas, indexado por AZ. |
| `nat_gateway_ids` | Mapa de IDs dos NAT Gateways, indexado por AZ. |

## Como usar

Configure o provider AWS no módulo raiz e chame este módulo:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  project        = "minha-aplicacao"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
}
```

Para selecionar AZs manualmente, informe pelo menos duas em `availability_zones`. Quando essa variável é preenchida, `availability_zone_count` não determina a seleção.

## Requisitos

- Terraform `>= 1.5.0`
- AWS provider `~> 5.0`
- Provider AWS configurado pelo módulo raiz, com região e credenciais válidas

O módulo não configura backend remoto nem workspaces; esses itens devem ser definidos na configuração raiz que o consome.
