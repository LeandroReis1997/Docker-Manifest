#!/usr/bin/env bash
set -euo pipefail

DUMP_FILE="${1:-filazero_db_local_dump.sql}"

if [ ! -f ".env" ]; then
  echo "Arquivo .env nao encontrado no diretorio atual."
  exit 1
fi

if [ ! -f "$DUMP_FILE" ]; then
  echo "Dump nao encontrado: $DUMP_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

DB_NAME="${DB_NAME:-filazero_db}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD nao definido no .env}"

BACKUP_FILE="backup-${DB_NAME}-antes-import-$(date +%Y%m%d-%H%M%S).sql"
TMP_DUMP="$(mktemp)"

cleanup() {
  rm -f "$TMP_DUMP"
}
trap cleanup EXIT

echo "Gerando backup atual em: $BACKUP_FILE"
docker compose exec -T \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  -e DB_NAME="$DB_NAME" \
  mysql sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --databases "$DB_NAME"' > "$BACKUP_FILE"

echo "Preparando dump para o banco: $DB_NAME"
sed "s/\`filazero_db\`/\`$DB_NAME\`/g" "$DUMP_FILE" > "$TMP_DUMP"

echo "Importando dump. Isto recria tabelas e registros do banco $DB_NAME."
docker compose exec -T \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$TMP_DUMP"

echo "Validando tabelas importadas..."
docker compose exec -T \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  -e DB_NAME="$DB_NAME" \
  mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
USE \`$DB_NAME\`;
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = '\''BASE TABLE'\''
ORDER BY TABLE_NAME;
"'

echo "Importacao finalizada."
