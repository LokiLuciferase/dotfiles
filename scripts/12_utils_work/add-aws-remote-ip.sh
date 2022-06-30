#!/usr/bin/env bash
set -euo pipefail

############### Global Variables ##########
SCRIPT_PATH="`dirname \"$0\"`"
INGRESS_PORT=22
ACCOUNT_NAME=rnd
AWSCLI_PROFILE=rnd
SECURITY_GROUP_ID="$1"
###########################################

echo -n "Purge obsolete ingress rules? [y/N] "
read yn_purge
if [[ "$yn_purge" = "y" ]]; then
    echo "Loading Security Group information..."
    RULES_TO_REVOKE=$(aws --profile $AWSCLI_PROFILE ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID --output text | grep IPRANGES | grep -v "0.0.0.0" | grep -v "KEEP" | cut -f2 | tr '\n' ' ')
    for rule in ${RULES_TO_REVOKE[@]}; do
        echo "Revoking ingress rule $rule..."
        AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 revoke-security-group-ingress --group-id $SECURITY_GROUP_ID --cidr $rule --protocol tcp --port $INGRESS_PORT
    done
fi

PUBLIC_IP=$(curl -s ifconfig.me)
echo -n "Add the current public IP ($PUBLIC_IP) to your DMZ security group in account ${ACCOUNT_NAME}? [y/N] "
read yn_add
[[ "$yn_add" != "y" ]] && exit 0

AWS_PAGER="" aws --profile $AWSCLI_PROFILE ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port $INGRESS_PORT \
  --cidr ${PUBLIC_IP}/32

