# Docker-Manifest

Este diretório contém a configuração de orquestração Docker Compose para os projetos FilaZero Admin (backend e frontend) e Caddy como servidor web.

## Como usar

- Antes de fazer pull das imagens, faça login no ECR:

```bash
# Windows (PowerShell)
./ecr-login.ps1

# Linux/macOS
./ecr-login.sh
```

- Construa e inicie os serviços:

```bash
docker compose up -d
```

- Pare os serviços:

```bash
docker compose down
```

Os serviços são:
- `mysql`
- `redis`
- `backend`
- `frontend`
- `caddy`

Configuração de domínios:
- Frontend: `painel.filazerobrasil.com.br`
- API: `api.filazerobrasil.com.br`

O Caddy serve o frontend pelo domínio `painel.filazerobrasil.com.br` e faz proxy para o backend no domínio da API.

As imagens do backend e do frontend são carregadas do Amazon ECR com tag `v1.0.0`.
