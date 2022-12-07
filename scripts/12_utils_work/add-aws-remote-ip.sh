#!/usr/bin/env bash
set -euo pipefail

############### Global Variables ##########
SCRIPT_PATH="`dirname \"$0\"`"
INGRESS_PORT=22
ACCOUNT_NAME=rnd
AWSCLI_PROFILE=rnd
SECURITY_GROUP_ID="$1"
###########################################

maybe_aws_sso_login() {
    set +e
    aws s3 --profile ${AWSCLI_PROFILE} ls &> /dev/null
    [ "$?" -eq 0 ] && return
    echo "Need to login to AWS SSO first."
    aws sso login
    set -e
}

purge_existing_rules() {
    echo "Loading Security Group information..."
    local rules_to_revoke
    rules_to_revoke=$(aws --profile $AWSCLI_PROFILE ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID --output text | grep IPRANGES | grep -v "0.0.0.0" | grep -v "KEEP" | cut -f2 | tr '\n' ' ')
    for rule in ${rules_to_revoke[@]}; do
        echo "Revoking ingress rule $rule..."
        AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 revoke-security-group-ingress --group-id $SECURITY_GROUP_ID --cidr $rule --protocol tcp --port $INGRESS_PORT
    done
}

add_current_ip() {
    AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 authorize-security-group-ingress \
      --group-id $SECURITY_GROUP_ID \
      --protocol tcp \
      --port $INGRESS_PORT \
      --cidr $1/32
}

main() {
    maybe_aws_sso_login
    echo -n "Purge obsolete ingress rules? [y/N] "
    read yn_purge
    if [[ "$yn_purge" = "y" ]]; then
        purge_existing_rules
    fi

    local public_ip
    public_ip=$(curl -s ifconfig.me)
    echo -n "Add the current public IP ($public_ip) to your DMZ security group in account ${ACCOUNT_NAME}? [y/N] "
    read yn_add
    if [[ "$yn_add" = "y" ]]; then
        add_current_ip $public_ip
    fi
}

main
