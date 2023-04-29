#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TIMESTAMP="$(date +%s)"

echo -n "FILENAME_SUFFIX: "
read -r FILENAME_SUFFIX

echo -n "SUMMARY: "
read -r SUMMARY

echo -n "Desktop only? [y/N]: "
read -r DESKTOP_ONLY

FILENAME="${SCRIPT_DIR}/migrations/${TIMESTAMP}_${FILENAME_SUFFIX}.sh"

cat << EOF > "${FILENAME}"
#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: $SUMMARY
# ISSUED: $(date --rfc-3339=seconds)
# ---
EOF

if [[ "${DESKTOP_ONLY}" =~ ^[Yy]$ ]]; then
    cat << 'EOF' >> "${FILENAME}"
if [ -z "$(ls -A ~/.dotfiles/datafiles/ || true)" ]; then
    echo "Skipping desktop-only migration."
    exit 0
else
    echo "Running desktop-only migration."
fi

EOF
else
    echo >> "${FILENAME}"
fi

nvim + "${FILENAME}"
