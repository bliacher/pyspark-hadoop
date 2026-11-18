
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/stop-spark.sh"
"$SCRIPT_DIR/stop-hdfs.sh"

echo "All services stopped."

