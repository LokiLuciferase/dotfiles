#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mkdir -p "${DIR}/logs"

bash "${DIR}/05_setup_conda.sh" |& tee -a "${DIR}/logs/05_setup_conda.log"
bash "${DIR}/07_install_packages.sh" |& tee -a "${DIR}/logs/07_install_packages.log"
bash "${DIR}/10_setup_env.sh" |& tee -a "${DIR}/logs/10_setup_env.log"
