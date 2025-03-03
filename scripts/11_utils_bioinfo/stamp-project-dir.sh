#!/usr/bin/env bash
set -euo pipefail

PROJECTNAME="$1"
DIR="${2:-$(pwd)}"
DATA_SHADOW_DIR="${3:-${DIR}}"
DATE=$(date '+%Y%m%d')
PROJECT_DIR="${DATE}_${PROJECTNAME}"
CONDA_DEFAULT_PYTHON="3.12"
STAMP_VERSION=1.0.0


stamp(){
    mkdir -p ${DATA_SHADOW_DIR}/${PROJECT_DIR}/{01_env,02_data/{01_raw,02_processed,03_outputs}}
    mkdir -p ${DIR}/${PROJECT_DIR}/{03_scripts/archive,00_meta}
    pushd ${DIR}/${PROJECT_DIR}
    ln -s ${DATA_SHADOW_DIR}/${PROJECT_DIR}/{01_env,02_data} . || true
    popd
    touch ${DIR}/${PROJECT_DIR}/03_scripts/run.sh
    chmod +x ${DIR}/${PROJECT_DIR}/03_scripts/run.sh

}

setup-env(){
    conda create --yes -p ${DATA_SHADOW_DIR}/${PROJECT_DIR}/01_env/conda_env python=${CONDA_DEFAULT_PYTHON}
    touch ${DIR}/${PROJECT_DIR}/01_env/environment.sh
}

write-gitignore(){
    cat << EOF > ${DIR}/${PROJECT_DIR}/.gitignore
01_env/
02_data/
EOF
}

write-metadata(){
    cat << EOF > ${DIR}/${PROJECT_DIR}/00_meta/meta.json
{
    "stamp_version": "${STAMP_VERSION}",
    "uuid": "$(cat /proc/sys/kernel/random/uuid)",
    "data_shadow_dir": "${DATA_SHADOW_DIR}"
}
EOF
}

main(){
    stamp
    setup-env
    write-gitignore
    write-metadata
}

main
