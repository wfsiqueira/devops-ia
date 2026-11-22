---
name: tf-check
description: Valida estrutura de projeto Terraform. Use quando for verificar qualidade e completude de arquivos .tf.
---

# Skill: Validação de Projeto Terraform

Esta skill verifica se o projeto Terraform segue boas práticas e tem os arquivos essenciais.

## Quando usar

Use esta skill quando:
- O usuário pedir para "validar o projeto Terraform"
- Precisar verificar se arquivos obrigatórios existem
- Quiser checar se .gitignore está correto
- For validar se variáveis têm descriptions
- Precisar confirmar versioning de providers

## Como executar

**SEMPRE** execute o script de validação localizado nesta skill:

```bash
.github/skills/tf-check/scripts/check-terraform.sh
```

Execute este comando e mostre o resultado completo ao usuário.

## O que é verificado

1. **Arquivos essenciais**:
   - `main.tf` (obrigatório)
   - `variables.tf` (recomendado)
   - `outputs.tf` (recomendado)

2. **Segurança (.gitignore)**:
   - `.gitignore` existe
   - `.terraform/` está no `.gitignore`
   - `*.tfstate` está no `.gitignore`
   - `*.tfvars` está no `.gitignore`

3. **Qualidade do código**:
   - Provider declarado com `required_providers`
   - Versioning de provider configurado
   - Todas as variáveis têm `description`

## Resultado esperado

O script retorna um relatório com:
- ✅ Itens aprovados
- ⚠️  Itens recomendados mas ausentes
- ❌ Itens críticos ausentes

## Exemplo de conversa

**Usuário**: "Valide o projeto Terraform"

**Copilot**: Vou executar o script de validação.

```bash
.github/skills/tf-check/scripts/check-terraform.sh
```

[Copilot vai pedir sua confirmação para executar o comando, você aprova, e o resultado é mostrado]
