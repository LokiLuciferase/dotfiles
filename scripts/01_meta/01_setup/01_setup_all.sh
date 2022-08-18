#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

bash "${DIR}/05_setup_conda.sh"
bash "${DIR}/07_install_packages.sh"
bash "${DIR}/10_setup_env.sh"
