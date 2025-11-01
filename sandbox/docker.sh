#!/bin/bash

set -e

test_code() {
    local url="$1"
    local code="`curl -o /dev/null -I -L -s -w "%{http_code}" "$url"`"
    test "$code" -lt 300 -a "$code" -ge 200
}

cleanup() {
    find /tmp/docker-config -maxdepth 1 -mindepth 1 -mmin +60 | while read job_dir; do
        job_url_file="$job_dir/job_url.conf"
        if ! [ -f "$job_url_file" ] || ! test_code "`cat "$job_url_file"`"; then
            rm -rf "$job_dir"
        else
            touch "$job_dir"
        fi
    done
}

if [ -z "$DOCKER_CONFIG" ]; then
    cleanup
    if [ -n "$CI_JOB_ID" -a -n "$CI_SERVER_URL" -a -n "$CI_JOB_TOKEN" ]; then
        job_url="$CI_SERVER_URL/api/v4/job?job_token=$CI_JOB_TOKEN"
        docker_config="/tmp/docker-config/job-$CI_JOB_ID"
        if [ ! -d "$docker_config" ]; then
            if test_code "$job_url"; then
                mkdir -p "$docker_config"
                echo "$job_url" > "$docker_config/job_url.conf"
                export DOCKER_CONFIG="$docker_config"
            fi
        else
            export DOCKER_CONFIG="$docker_config"
        fi
    fi
fi

exec docker.bin "$@"
