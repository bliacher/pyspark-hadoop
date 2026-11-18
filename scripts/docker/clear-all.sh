
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "WARNING: This will remove all project containers,"
echo "networks, and persistent Docker volumes."
echo ""
echo "All data stored in HDFS will be deleted."
echo "Local project files and bind-mounted directories are preserved."
echo ""

read -r -p "Type DELETE to continue: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
  echo "Operation cancelled."
  exit 1
fi

"$SCRIPT_DIR/stop-all.sh"

echo "Removing Docker resources..."

docker compose down --volumes --remove-orphans

echo "Docker environment cleared."

