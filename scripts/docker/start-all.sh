
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/start-hdfs.sh"
"$SCRIPT_DIR/start-spark.sh"

echo "All services started."

