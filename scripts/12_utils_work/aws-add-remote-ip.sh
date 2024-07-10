#!/usr/bin/env bash
set -euo pipefail

############### Global Variables ##########
INGRESS_PORT=22
ACCOUNT_NAME=sandbox
AWSCLI_PROFILE=${AWSCLI_PROFILE:-sandbox}
SECURITY_GROUP_ID="$1"
PUBLIC_IP="${2:-$(curl ifconfig.me)}"
###########################################

maybe_aws_sso_login() {
    set +e
    aws s3 --profile ${AWSCLI_PROFILE} ls &> /dev/null && return
    echo "Need to login to AWS SSO first."
    aws sso login
    set -e
}

purge_existing_rules() {
    echo "Loading Security Group information..."
    local rules_to_revoke
    rules_to_revoke=$(aws --profile $AWSCLI_PROFILE ec2 describe-security-groups --group-ids "$SECURITY_GROUP_ID" --output text | grep IPRANGES | grep -v "0.0.0.0" | grep '[[:blank:]]$' | cut -f2 | tr '\n' ' ')
    for rule in ${rules_to_revoke[@]}; do
        echo "Revoking ingress rule $rule..."
        AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 revoke-security-group-ingress --group-id "$SECURITY_GROUP_ID" --cidr "$rule" --protocol tcp --port $INGRESS_PORT
    done
}

add_current_ip() {
    AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 authorize-security-group-ingress \
      --group-id "$SECURITY_GROUP_ID" \
      --protocol tcp \
      --port $INGRESS_PORT \
      --cidr $1/32
}

main() {
    maybe_aws_sso_login
    echo -n "Purge obsolete ingress rules? [y/N] "
    read -r yn_purge
    if [[ "$yn_purge" = "y" ]]; then
        purge_existing_rules
    fi

    echo -n "Add the current public IP (${PUBLIC_IP}) to your DMZ security group in account ${ACCOUNT_NAME}? [Y/n] "
    read -r yn_add
    if [[ "$yn_add" != "n" ]]; then
        add_current_ip "${PUBLIC_IP}"
    fi
}

main
