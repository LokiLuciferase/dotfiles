#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="`dirname \"$0\"`"
AWSCLI_PROFILE=rnd
INSTANCE_NAME="${1:-llf-sandbox-v2}"


ensure_tools_present() {
    set +e
    if [ "$(which jq)" = '' ]; then
        echo "Dependency jq missing."
        exit 1
    elif [ "$(which aws)" = '' ]; then
        echo "Dependency awscli v2 missing."
        exit 1
    fi
    set -e
}

maybe_aws_sso_login() {
    set +e
    aws s3 ls &> /dev/null
    [ "$?" -eq 0 ] && return
    echo "Need to login to AWS SSO first."
    aws sso login
    set -e
}

get_instance_info() {
    INSTANCE_NAME="$1"
    AWSCLI_PROFILE="$2"
    RESULT=$(PAGER="" aws --profile ${AWSCLI_PROFILE} ec2 describe-instances --no-paginate --output json \
        | jq '.[] | .[].Instances[] | {instance_id: .InstanceId, instance_type: .InstanceType, tagname: .Tags[].Key, tagval: .Tags[].Value, ip: .PublicIpAddress, status: .State["Name"]} | select(.tagname=="Name")' \
        | jq -r "select(.tagval==\"$INSTANCE_NAME\") | [ .instance_id, .instance_type, .ip, .tagval, .status ] | .[]" \
        | tr '\n' '\t')
    echo "$RESULT"
}

do_toggle() {
    RESULT=($(get_instance_info $INSTANCE_NAME $AWSCLI_PROFILE))
    INSTANCE_ID="${RESULT[0]}"
    INSTANCE_TYPE="${RESULT[1]}"
    IP_ADDR="${RESULT[2]}"
    INSTANCE_STATUS="${RESULT[4]}"
    DESC_STR="${INSTANCE_NAME} (${INSTANCE_ID}) as ${INSTANCE_TYPE} in account rnd"
    YN_REMINDER="(y/N)"

    if [[ "${INSTANCE_STATUS}" = 'stopped' ]]; then
        echo -n "Start instance ${DESC_STR}? $YN_REMINDER "
        read start_yn
        if [[ "${start_yn}" = 'y' ]]; then
            echo "Starting instance."
            PAGER="" aws --profile ${AWSCLI_PROFILE} ec2 start-instances --instance-ids ${INSTANCE_ID} | jq .
        else
            echo "Aborting instance start."
        fi
    elif [[ "${INSTANCE_STATUS}" = 'running' ]]; then
        echo -n "Stop instance ${DESC_STR}? $YN_REMINDER "
        read stop_yn
        if [[ "${stop_yn}" = 'y' ]]; then
            echo "Stopping instance."
            PAGER="" aws --profile ${AWSCLI_PROFILE} ec2 stop-instances --instance-ids ${INSTANCE_ID} | jq .
        else
            echo "Aborting instance stop."
        fi
    else
        echo "Instance is in transitional status '${INSTANCE_STATUS}'. Try again later."
    fi
}

ensure_tools_present
maybe_aws_sso_login
do_toggle
