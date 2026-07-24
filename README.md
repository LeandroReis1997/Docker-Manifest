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

## Variáveis de ambiente

O arquivo `.env` é obrigatório e **não deve ser commitado** (está no `.gitignore`).

Na EC2 ou em ambiente novo:

```bash
cp .env.example .env
nano .env
```

Preencha senhas e chaves fortes. O `docker compose` falha na subida se faltar `JWT_SECRET`, credenciais do MySQL, AWS ou Resend.

### Migrations do banco

Na primeira vez em producao com schema ja existente:

```bash
docker compose exec backend npm run db:migrate:mark-baseline
```

Em releases com novas migrations:

```bash
docker compose exec backend npm run db:migrate
```

Arquivos que também não vão para o Git: `acessos`, `*.pem`, dumps `*.sql` e a pasta `data/`.

## Segurança de rede (produção)

Somente o Caddy deve ficar acessível pela internet (portas 80 e 443). MySQL, Redis, backend e frontend ficam apenas na rede interna do Docker.

Na **Security Group da EC2**, mantenha inbound público só para:
- TCP 80
- TCP 443
- TCP 22 (SSH), preferencialmente restrito ao seu IP

Remova regras públicas para 3307, 3306, 6379 e 4000, se existirem.

MySQL fica em `127.0.0.1:3307` **só dentro da EC2** (não acessível pela internet). A aplicação continua usando `mysql:3306` na rede Docker.

### Acessar o banco de produção (DBeaver / admin)

Use túnel SSH:

```bash
ssh -L 3307:127.0.0.1:3307 usuario@IP_DA_EC2
```

No DBeaver, conecte em `localhost:3307` com o usuário/senha do `.env` de produção.

Para abrir o shell do MySQL direto na EC2:

```bash
docker compose exec mysql sh -c 'mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

As imagens do backend e do frontend são carregadas do Amazon ECR com tag `v1.0.0`.
