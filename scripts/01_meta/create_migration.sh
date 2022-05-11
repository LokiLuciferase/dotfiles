#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TIMESTAMP="$(date +%s)"

echo -n "FILENAME_SUFFIX: "
read FILENAME_SUFFIX

echo -n "SUMMARY: "
read SUMMARY

FILENAME="${SCRIPT_DIR}/migrations/${TIMESTAMP}_${FILENAME_SUFFIX}.sh"

cat << EOF > "${FILENAME}"
#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: $FILENAME_SUFFIX
# SUMMARY: $SUMMARY
# ---

EOF

nvim -u ~/.SpaceVim/vimrc + "${FILENAME}"
