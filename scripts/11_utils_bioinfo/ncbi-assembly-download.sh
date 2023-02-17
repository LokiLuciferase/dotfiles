#!/usr/bin/env bash
set -uo pipefail

WGET_EXTRA_ARGS="${WGET_EXTRA_ARGS:-}"

ensure-tools-present() {
    local tools=(wget)
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo "ERROR: $tool is not installed" >&2
            exit 1
        fi
    done
}

ensure-ncbi-asm-summary-present() {
    local summary_type="$1"
    local summary_url="https://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_${summary_type}.txt"
    local summary_file="${TMPDIR:-/tmp}/assembly_summary_${summary_type}.txt"
    if [[ ! -f "$summary_file" ]]; then
        wget -O "$summary_file" "$summary_url"
        if [[ "$?" -ne 0 ]]; then
            echo "ERROR: Failed to download $summary_url" >&2
            rm "${summary_file}"
            exit 1
        fi
    fi
}

download-dir-url() {
    local url="$1"
    local out_dir_name="$2"
    wget \
        -e robots=off \
        -nH \
        --cut-dirs=100 \
        --recursive \
        --no-parent \
        --reject "index.html*" \
        --directory-prefix="${out_dir_name}" \
        "$url"
}

download-assembly-dirs-with-id() {
    local assemblies=("$@")
    local genome_dir_url
    for asm in "${assemblies[@]}"; do
        echo "Downloading $asm"
        genome_dir_url=$(grep -P "^$asm\t" "${TMPDIR:-/tmp}/assembly_summary_refseq.txt" | cut -f 20)
        download-dir-url "$genome_dir_url" "$asm"
    done
}

main(){
    POSITIONAL_ARGS=()
    DATABASE=refseq  # or genbank

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--database)
                DATABASE="$2"
                shift
                shift
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unknown flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                POSITIONAL_ARGS+=("$1")
                shift
                ;;
        esac
    done

    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
    ensure-tools-present
    ensure-ncbi-asm-summary-present "$DATABASE"
    download-assembly-dirs-with-id "${@}"
    rm "${TMPDIR:-/tmp}/assembly_summary_${DATABASE}.txt"
}

main "${@}"
