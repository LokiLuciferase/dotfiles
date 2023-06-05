#!/usr/bin/env bash

AWSCLI_PROFILE=$1

# Figure out temporary credentials.
SSO_ROLE=$(aws --profile ${AWSCLI_PROFILE} sts get-caller-identity --query=Arn | cut -d'_' -f 2)
SSO_ACCOUNT=$(aws --profile ${AWSCLI_PROFILE} sts get-caller-identity --query=Account --output text)
SESSION_FILE=$(find ~/.aws/sso/cache -type f -regex ".*/cache/[a-z0-9]*.json" | head -n 1)
SSO_ACCESS_TOKEN=$(jq -r '.accessToken' "$SESSION_FILE")
CREDENTIALS=$(aws --profile ${AWSCLI_PROFILE} sso get-role-credentials --role-name="$SSO_ROLE" --account-id="$SSO_ACCOUNT" --access-token="$SSO_ACCESS_TOKEN")
AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.roleCredentials.accessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.roleCredentials.secretAccessKey')
AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.roleCredentials.sessionToken')

if [ "$2" = "export" ]; then
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
else
    echo -ne "$AWS_ACCESS_KEY_ID\t$AWS_SECRET_ACCESS_KEY\t$AWS_SESSION_TOKEN"
fi
