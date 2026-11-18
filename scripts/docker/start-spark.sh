
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Starting Apache Spark..."

docker compose up -d \
  spark-master \
  spark-worker \
  spark-client

echo "Spark services started."

