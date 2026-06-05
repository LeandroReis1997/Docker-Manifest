#!/bin/bash
# ECR Docker Login Script
# Autentica Docker no Amazon ECR para puxar imagens
# Usage: ./ecr-login.sh

REGION=${1:-us-east-1}
AWS_PROFILE=${2:-default}
AWS_ACCOUNT_ID="171430923691"
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "Autenticando Docker no ECR..."
echo "Registry: $ECR_REGISTRY"
echo "Region: $REGION"
echo "Profile: $AWS_PROFILE"

# Get login token from AWS ECR and pipe to docker login
aws ecr get-login-password --region $REGION --profile $AWS_PROFILE | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

if [ $? -eq 0 ]; then
    echo "✓ Autenticacao bem-sucedida!"
    echo "Agora voce pode fazer pull de imagens do ECR:"
    echo "  docker pull $ECR_REGISTRY/filazero-admin-backend:v1.0.0"
    echo "  docker pull $ECR_REGISTRY/filazero-admin-frontend:v1.0.0"
else
    echo "✗ Erro ao fazer login no Docker."
    exit 1
fi
