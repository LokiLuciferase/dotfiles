#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LATEST_MIGRATION="$(ls -t ${SCRIPT_DIR}/migrations/ | head -1)"

[ -z "${LATEST_MIGRATION}" ] && echo "No pending migrations found." && exit 0

echo "Execute latest migration ($(basename $LATEST_MIGRATION))? [y/N]"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Executing migration..."
    bash "${SCRIPT_DIR}/migrations/${LATEST_MIGRATION}"
else
    echo "Skipping migration..."
fi
