
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Stopping Hadoop HDFS..."

docker compose stop datanode namenode

echo "HDFS services stopped."

