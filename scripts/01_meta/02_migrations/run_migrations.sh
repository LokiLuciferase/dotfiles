#!/usr/bin/env bash
set -euo pipefail

get_migrations(){
    local migration_files=($(ls "${ACTIVE_MIGRATIONS_DIR}"/*.sh 2> /dev/null || true))
    local considered_migration_files=()
    for file in "${migration_files[@]}"; do
        if [[ "$(ls ${DONE_MIGRATIONS_DIR} | grep $(basename ${file}))" ]]; then
            continue
        fi
        considered_migration_files+=("$file")
    done
    echo "${considered_migration_files[@]}"
}

parse_migration_dt(){
    local migration_file="$1"
    local dt=$(basename "${migration_file}" | cut -d'_' -f1)
    date -d "@${dt}"
}

get_migration_summary(){
    local migration_file="$1"
    local summary=$(grep "^# SUMMARY:" "${migration_file}" | sed -e 's/^# SUMMARY://')
    [[ -z "${summary}" ]] && summary="No summary provided"
    echo "${summary}"
}

source_env() {
    source ~/.dotfiles/zsh/common/functions.zsh
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIVE_MIGRATIONS_DIR="${SCRIPT_DIR}/migrations"
DONE_MIGRATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/done_migrations"
mkdir -p "$DONE_MIGRATIONS_DIR"
MIGRATIONS_TO_APPLY=($(get_migrations))

source_env
[[ ${#MIGRATIONS_TO_APPLY[@]} -eq 0 ]] && cecho G "No dotfile migrations to apply." && exit 0
echo "Running ${#MIGRATIONS_TO_APPLY[@]} dotfile migration(s):"
for migration in "${MIGRATIONS_TO_APPLY[@]}"; do
    echo "  $(parse_migration_dt "$migration") - $(basename "$migration") - $(get_migration_summary "$migration")"
done
echo ""
echo "Is this correct? [y/N]"
read -r answer
[[ ! $answer =~ ^([yY][eE][sS]|[yY])$ ]] && cecho R "Aborting." && exit 1
for file in "${MIGRATIONS_TO_APPLY[@]}"; do
    echo -n "Running '$(basename "$file")'..."
    set +e
    bash "$file"
    [[ "$?" -eq 0 ]] && cecho G "OK" || cecho Y "Exit code $?"
    cp "$file" "$DONE_MIGRATIONS_DIR"
    set -e
done
