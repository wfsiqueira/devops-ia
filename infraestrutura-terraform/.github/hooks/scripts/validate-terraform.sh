#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"bash":"[^"]*"' | cut -d'"' -f4)

echo "=== Validação de Comando Terraform/Bash ===" >&2
echo "Comando solicitado: $COMMAND" >&2

# Comandos perigosos bloqueados
DANGEROUS_COMMANDS="rm -rf|dd|mkfs|format|terraform destroy --auto-approve|terraform apply.*--auto-approve.*-target"

# Comandos que precisam confirmação
SENSITIVE_COMMANDS="terraform destroy|terraform apply --auto-approve|aws.*delete|terraform state rm"

# Valida se está no workspace correto
if echo "$COMMAND" | grep -q "terraform apply\|terraform destroy"; then
  CURRENT_WORKSPACE=$(terraform workspace show 2>/dev/null || echo "default")
  echo "  Workspace atual: $CURRENT_WORKSPACE" >&2

  if [ "$CURRENT_WORKSPACE" = "prod" ]; then
    echo "⚠️  AVISO: Operação em PRODUÇÃO!" >&2
  fi
fi

if echo "$COMMAND" | grep -qE "$DANGEROUS_COMMANDS"; then
  echo "❌ BLOQUEADO: Comando perigoso!" >&2
  echo '{"approved": false, "reason": "Comando perigoso bloqueado"}' >&1
  exit 1
elif echo "$COMMAND" | grep -qE "$SENSITIVE_COMMANDS"; then
  echo "⚠️  AVISO: Comando sensível detectado" >&2
  echo '{"approved": true, "warning": "Comando destrutivo - confirme antes de executar"}' >&1
  exit 0
else
  echo "✅ APROVADO: Comando seguro" >&2
  echo '{"approved": true}' >&1
  exit 0
fi
