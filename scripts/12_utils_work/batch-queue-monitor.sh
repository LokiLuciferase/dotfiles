#!/usr/bin/env bash
set -euo pipefail

ensure_tools_present() {
    which jq &> /dev/null || {
        echo "jq is not installed"
        exit 1
    }
    which aws &> /dev/null || {
        echo "aws is not installed"
        exit 1
    }
}

get_queue_names() {
    PAGER='' aws batch --region eu-central-1 describe-job-queues | jq '[ .jobQueues[].jobQueueName ]| sort | .[]' -r
}

get_batch_job_adjective_count() {
    local queue_name=$1
    local adjective=$2
    PAGER='' aws batch --region eu-central-1 list-jobs --job-queue $queue_name --job-status $adjective | jq '.jobSummaryList | length' -r
}

get_queue_info(){
    local queue_name=$1
    local n_runnable
    local n_running
    local n_succeeded
    local n_failed
    local out
    n_runnable=$(get_batch_job_adjective_count "$queue_name" RUNNABLE &)
    n_running=$(get_batch_job_adjective_count "$queue_name" RUNNING &)
    n_succeeded=$(get_batch_job_adjective_count "$queue_name" SUCCEEDED &)
    n_failed=$(get_batch_job_adjective_count "$queue_name" FAILED &)
    wait
    out="$queue_name\t$n_runnable\t$n_running\t$n_succeeded\t$n_failed\n"
    printf "$out"
}

main(){
    ensure_tools_present
    local queue_names
    queue_names=$(get_queue_names)
    printf "queue\trunnable\trunning\tsucceeded\tfailed\n"
    for queue_name in $queue_names; do
        get_queue_info "$queue_name"
    done
    wait
}

main
