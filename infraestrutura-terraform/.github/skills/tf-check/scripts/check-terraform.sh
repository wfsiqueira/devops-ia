#!/bin/bash

echo "=== Verificação de Projeto Terraform ==="
echo ""

# Verifica arquivos obrigatórios
if [ -f "main.tf" ]; then
  echo "✅ main.tf encontrado"
else
  echo "❌ main.tf não encontrado (OBRIGATÓRIO)"
fi

if [ -f "variables.tf" ]; then
  echo "✅ variables.tf encontrado"
else
  echo "⚠️  variables.tf não encontrado (recomendado)"
fi

if [ -f "outputs.tf" ]; then
  echo "✅ outputs.tf encontrado"
else
  echo "⚠️  outputs.tf não encontrado (recomendado)"
fi

# Verifica .gitignore
if [ -f ".gitignore" ]; then
  echo "✅ .gitignore encontrado"

  # Verifica entradas essenciais
  if grep -q ".terraform" .gitignore; then
    echo "  ✅ .terraform/ está no .gitignore"
  else
    echo "  ❌ .terraform/ NÃO está no .gitignore (CRÍTICO)"
  fi

  if grep -q "tfstate" .gitignore; then
    echo "  ✅ *.tfstate está no .gitignore"
  else
    echo "  ❌ *.tfstate NÃO está no .gitignore (CRÍTICO)"
  fi

  if grep -q "tfvars" .gitignore; then
    echo "  ✅ *.tfvars está no .gitignore"
  else
    echo "  ⚠️  *.tfvars não está no .gitignore (recomendado)"
  fi
else
  echo "❌ .gitignore não encontrado (CRÍTICO)"
fi

# Verifica provider no main.tf
if [ -f "main.tf" ]; then
  if grep -q "required_providers" main.tf; then
    echo "✅ Provider declarado em main.tf"
  else
    echo "⚠️  Provider não encontrado em main.tf"
  fi

  # Verifica se tem versioning
  if grep -q "version.*=" main.tf; then
    echo "✅ Versioning de provider configurado"
  else
    echo "⚠️  Versioning de provider não encontrado"
  fi
fi

# Verifica se variables tem description
if [ -f "variables.tf" ]; then
  VAR_COUNT=$(grep -c "^variable" variables.tf)
  DESC_COUNT=$(grep -c "description" variables.tf)

  echo "✅ Variáveis encontradas: $VAR_COUNT"
  echo "✅ Descriptions encontradas: $DESC_COUNT"

  if [ "$VAR_COUNT" -eq "$DESC_COUNT" ]; then
    echo "  ✅ Todas as variáveis têm description"
  else
    echo "  ⚠️  Algumas variáveis sem description"
  fi
fi

echo ""
echo "=== Verificação concluída ==="
