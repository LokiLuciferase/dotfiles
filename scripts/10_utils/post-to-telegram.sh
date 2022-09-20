#!/usr/bin/env bash
set -euo pipefail


ensure_tools_present() {
    local tools=( curl )
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo "ERROR: $tool is not installed" >&2
            exit 1
        fi
    done
    return 0
}

ensure_env_vars_present() {
    local env_vars=( TG_CHAT_ID TG_BOT_TOKEN )
    for env_var in "${env_vars[@]}"; do
        if [[ -z "${env_var}" ]]; then
            echo "ERROR: $env_var is not set" >&2
            exit 1
        fi
    done
    return 0
}

post_to_tg() {
    local msg="$1"
    local tg_bot_token="${TG_BOT_TOKEN}"
    local tg_chat_id="${TG_CHAT_ID}"
    local tg_api_url="https://api.telegram.org/bot$tg_bot_token/sendMessage"
    local tg_msg="$msg"
    local tg_msg_url_encoded="$(echo "$tg_msg" | sed 's/ /%20/g')"
    local tg_api_call="$tg_api_url?chat_id=$tg_chat_id&text=$tg_msg_url_encoded"
    local response=$(curl -s "$tg_api_call")
    if [ ! -z "$(which jq)" ]; then
        local response_json="$(echo "$response" | jq -r .)"
        local response_ok="$(echo "$response_json" | jq -r .ok)"
        if [ "$response_ok" != "true" ]; then
            echo "ERROR: Telegram API call failed" >&2
            echo "ERROR: $response_json" >&2
            exit 1
        fi
    else
        echo "$response"
    fi
    return 0
}

__MAIN__() {
    ensure_tools_present
    ensure_env_vars_present
    post_to_tg "$1"
    return 0
}

__MAIN__ "$@"
