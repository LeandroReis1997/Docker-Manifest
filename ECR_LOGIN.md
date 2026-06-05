# Autenticação ECR

Este diretório contém scripts para autenticar o Docker no Amazon ECR e fazer pull das imagens automaticamente.

## Pré-requisitos

- AWS CLI v2 instalado e configurado com credenciais válidas
- Docker instalado
- Acesso à conta AWS com permissões ECR

## Configuração das credenciais AWS

Se você ainda não configurou a AWS CLI:

```bash
aws configure
```

Você será solicitado a fornecer:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (use: `us-east-1`)
- Default output format (deixe em branco ou use `json`)

## Scripts de login

### Windows (PowerShell)

```powershell
./ecr-login.ps1
```

Ou com parâmetros customizados:

```powershell
./ecr-login.ps1 -Region us-east-1 -AwsProfile default
```

### Linux / macOS

```bash
chmod +x ecr-login.sh
./ecr-login.sh
```

Ou com parâmetros customizados:

```bash
./ecr-login.sh us-east-1 default
```

## Uso com docker compose

Antes de rodar `docker compose up`, execute o script de login:

```bash
# Windows
./ecr-login.ps1

# Linux/Mac
./ecr-login.sh

# Depois
docker compose up -d
```

## Validar login

Você pode validar se o login funcionou tentando fazer pull de uma imagem:

```bash
docker pull 171430923691.dkr.ecr.us-east-1.amazonaws.com/filazero-admin-backend:v1.0.0
```

## Renovar token

O token ECR expira a cada 12 horas. Você pode rodar o script novamente para renovar:

```bash
./ecr-login.ps1  # ou ./ecr-login.sh
```

## GitHub Actions

Para o GitHub Actions fazer login automaticamente, use o role OIDC configurado no workflow:

```yaml
- name: Configure AWS credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::171430923691:role/GitHubActionsOIDCRole
    aws-region: us-east-1

- name: Login to Amazon ECR
  uses: aws-actions/amazon-ecr-login@v1
```

Isso será feito automaticamente pelos workflows de build.
