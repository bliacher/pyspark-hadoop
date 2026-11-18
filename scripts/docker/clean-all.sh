
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "WARNING: This will remove:"
echo "  - Spark and Hadoop containers"
echo "  - Docker Compose network"
echo "  - HDFS NameNode and DataNode volumes"
echo ""
echo "Local apps/, data/, output/, events/, and work/ will remain."
echo ""

read -r -p "Type DELETE to confirm: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
    echo "Operation cancelled."
    exit 1
fi

docker compose down --volumes --remove-orphans

echo "Docker environment cleaned."
echo "HDFS must be formatted again before restarting."

