#!/usr/bin/env bash
set -euo pipefail


if [[ "$1" == "s3:"* ]]; then
    ref=${1#s3://}
    refspl=($(python -c "print('$ref'.split('/')[0], '$ref'.split('/', maxsplit=1)[1])" "$ref"))
    bucket=${refspl[0]}
    key=${refspl[1]}
    xdg-open "https://console.aws.amazon.com/s3/buckets/${bucket}?region=eu-central-1&prefix=${key}"
else
    xdg-open "$1" # Just open with the default handler
fi
