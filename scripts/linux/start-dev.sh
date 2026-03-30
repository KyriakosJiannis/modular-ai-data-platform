#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"
ENV_FILE="$REPO_ROOT/config/env/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy config/env/.env.example first."
  exit 2
fi

echo "Starting Harmonia - Developer Stack"
echo "This starts the default stack plus direct localhost access to core data services."
echo "Main entry point: http://ai.localhost"
echo "Direct access: PostgreSQL 5432, MongoDB 27017, Qdrant 6333, MinIO 9000"

cd "$COMPOSE_DIR"
docker compose \
  --env-file "$ENV_FILE" \
  -f docker-compose.yml \
  -f docker-compose.tools.yml \
  -f docker-compose.dev-core.yml \
  --profile infra \
  --profile tools \
  up -d

echo
echo "Dashboard: http://ai.localhost"
echo "OpenWebUI: http://openwebui.localhost"
echo "MLflow: http://mlflow.localhost"
echo "Adminer: http://db.localhost"
echo
echo "Direct access:"
echo "PostgreSQL: localhost:5432"
echo "MongoDB: localhost:27017"
echo "Qdrant: localhost:6333"
echo "MinIO: localhost:9000"
