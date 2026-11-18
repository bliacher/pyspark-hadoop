
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Checking HDFS initialization..."

"$PROJECT_ROOT/scripts/hdfs/format.sh"

echo "Starting Hadoop HDFS..."

docker compose up -d namenode datanode

echo "HDFS services started."

