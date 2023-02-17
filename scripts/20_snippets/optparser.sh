POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arg1)
            ARG1="$2"
            shift
            shift
            ;;
        -f|--flag)
            FLAG=true
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
