#!/bin/bash

# Garante que o status de saída de um pipe seja o do último comando que falhou.
set -eo pipefail

# --- Banco de Dados MongoDB ---
MONGO_DATABASE="${MONGO_DATABASE:-database}"
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"

# --- Credenciais---
MONGO_USER="${MONGO_USER:-}"
MONGO_PASSWORD="${MONGO_PASSWORD:-}"
MONGO_AUTH_DB="${MONGO_AUTH_DB:-}"

# --- Configurações de Diretório e GCS ---
GCS_BUCKET_PATH="gs://bucket/backup_mongodb/"

# Cria um diretório temporário
TEMP_DIR=$(mktemp -d)
# Limpeza dos arquivos
trap 'rm -rf "${TEMP_DIR}"' EXIT
printf -- "--- Início do Processo de Backup: %s ---\n" "$(date)"
printf -- "Diretório de trabalho temporário: %s\n" "${TEMP_DIR}"


# Define o nome e o caminho do arquivo de backup
TIMESTAMP=$(date +'%F_%T')
BACKUP_FILENAME="${MONGO_DATABASE}_${TIMESTAMP}.gz"
BACKUP_FILEPATH="${TEMP_DIR}/${BACKUP_FILENAME}"

# Monta os argumentos de autenticação apenas se um usuário for fornecido.
AUTH_ARGS=""
if [[ -n "${MONGO_USER}" ]]; then
  AUTH_ARGS="--username=${MONGO_USER} --password=${MONGO_PASSWORD} --authenticationDatabase=${MONGO_AUTH_DB}"
fi

# Executa o backup para .gzip.
printf -- "[1/3] Iniciando backup do banco de dados '%s'...\n" "${MONGO_DATABASE}"

eval mongodump \
  --host="${MONGO_HOST}" \
  --port="${MONGO_PORT}" \
  "${AUTH_ARGS}" \
  --db="${MONGO_DATABASE}" \
  --archive="${BACKUP_FILEPATH}" \
  --gzip

printf -- "      Backup  concluído com sucesso.\n"

# Envia o arquivo de backup para o Google Cloud Storage.
printf -- "[2/3] Enviando backup para o GCS em '%s%s'...\n" "${GCS_BUCKET_PATH}" "${BACKUP_FILENAME}"

gcloud storage cp "${BACKUP_FILEPATH}" "${GCS_BUCKET_PATH}${BACKUP_FILENAME}"
printf -- "      Upload para o GCS concluído.\n"

# Remove o arquivo de backup local.
printf -- "[3/3] Limpeza do diretório temporário.\n"
printf -- "--- Processo finalizado com sucesso: %s ---\n" "$(date)"
