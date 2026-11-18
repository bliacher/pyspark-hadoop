
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

TARGET="${1:-/}"

hdfs_check
hdfs_validate_path "$TARGET"

hdfs_exec -ls "$TARGET"

