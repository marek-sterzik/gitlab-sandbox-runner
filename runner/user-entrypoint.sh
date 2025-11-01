#!/bin/bash

set -e

load_bool() {
    local val
    val="$1"
    if [ -z "$val" ]; then
        val="$2"
    fi
    val="`echo "$val" | awk '{print tolower($0)}'`"
    if [ "1" = "$val" -o "yes" = "$val" -o "true" = "$val" ]; then
        echo 1
    elif [ "0" = "$val" -o "no" = "$val" -o "false" = "$val" ]; then
        echo 0
    fi
}

load_int() {
    local val
    val="$1"
    if [ -z "$val" ]; then
        val="$2"
    fi
    if echo "$val" | grep -q '^[0-9]\+$'; then
        val="`expr "$val" + 0`"
        echo "$val"
    fi
}

create_user_env() {
    mkdir -p .ssh
    chmod go-rwx .ssh
    touch .ssh/known_hosts
    if [ -d ".gitlab-runner" -a ! -L ".gitlab-runner" ]; then
        rm -rf .gitlab-runner
    fi
    if [ ! -L ".gitlab-runner" ]; then
        ln -s /persistent/gitlab-runner .gitlab-runner
    fi
    if [ -e ".gitlab-runner/config.toml" ]; then
        rm -f .gitlab-runner/config.toml
    fi
}

install_ssh_key() {
    touch .ssh/id_rsa .ssh/id_rsa.pub
    chmod go-rwx .ssh/id_rsa
    echo "$1" > .ssh/id_rsa
    ssh-keygen -f .ssh/id_rsa -y > .ssh/id_rsa.pub
}

check_env() {
    if [ -z "$GITLAB_URL" ]; then
        echo "Error: missing GITLAB_URL variable" 1>&2
        exit 1
    fi

    if [ -z "$GITLAB_TOKEN" ]; then
        echo "Error: missing GITLAB_TOKEN variable" 1>&2
        exit 1
    fi

    if [ -z "$SSH_CONNECT" ]; then
        echo "Error: missing SSH_CONNECT variable" 1>&2
        exit 1
    fi

    if [ -z "$SSH_PASSWORD" -a -z "$SSH_KEY" ]; then
        echo "Error: missing SSH_KEY variable" 1>&2
        exit 1
    fi

    if [ -z "$SANDBOX_LOGIN_GITLAB_REGISTRY" ]; then
        echo "Error: invalid value of SANDBOX_LOGIN_GITLAB_REGISTRY variable (<bool>)" 1>&2
        exit 1
    fi

    if [ -z "$CONCURRENCY" -o "$CONCURRENCY" -lt 1 ]; then
        echo "Error: invalid value of CONCURRENCY variable (<int>)" 1>&2
        exit 1
    fi

    if echo "$GITLAB_URL" | grep -qv '^https\?://.*$' || [ "`echo "$GITLAB_URL" | wc -l`" -gt 1 ]; then
        echo "Error: invalid value of GITLAB_URL variable (<url>)" 1>&2
        exit 1
    fi

    if echo "$SSH_CONNECT" | grep -qv '^.\+@.\+$' || [ "`echo "$SSH_CONNECT" | wc -l`" -gt 1 ]; then
        echo "Error: invalid value of SSH_CONNECT variable (<user>@<host>[:<port>])" 1>&2
        exit 1
    fi
}

cd /home/gitlab-runner

SANDBOX_LOGIN_GITLAB_REGISTRY="`load_bool "$SANDBOX_LOGIN_GITLAB_REGISTRY" "true"`"
CONCURRENCY="`load_int "$CONCURRENCY" "1"`"

check_env
create_user_env

SSH_PORT=22
if echo "$SSH_CONNECT" | grep ':[0-9]\+$'; then
    SSH_PORT="`echo "$SSH_CONNECT" | sed 's/^.*:\([0-9]\+\)$/\1/'`"
    SSH_CONNECT="`echo "$SSH_CONNECT" | sed 's/:[0-9]\+$//'`"
    SSH_PORT="`expr "$SSH_PORT" + 0`"
    if [ "$SSH_PORT" -lt 1 -o "$SSH_PORT" -gt "65535" ]; then
        echo "Error: invalid ssh port" 1>&2
        exit 1
    fi
fi

SSH_HOST="`echo "$SSH_CONNECT" | sed 's/^.*@//'`"
SSH_USER="`echo "$SSH_CONNECT" | sed 's/@[^@]*$//'`"


runner_args=()

runner_args+=(--non-interactive --url "$GITLAB_URL" --token "$GITLAB_TOKEN" --executor ssh)

if [ -n "$RUNNER_NAME" ]; then
    runner_args+=(--name "$RUNNER_NAME")
fi

runner_args+=(--ssh-user "$SSH_USER" --ssh-host "$SSH_HOST" --ssh-port "$SSH_PORT")

runner_args+=(--ssh-password "$SSH_PASSWORD")

if [ -n "$SSH_KEY" ]; then
    install_ssh_key "$SSH_KEY"
    runner_args+=(--ssh-identity-file "/home/gitlab-runner/.ssh/id_rsa")
fi

if [ "$SANDBOX_LOGIN_GITLAB_REGISTRY" = "1" ]; then
    runner_args+=(--pre-build-script 'echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"')
fi

runner_args+=(--ssh-disable-strict-host-key-checking true)

runner_args+=(--request-concurrency "$CONCURRENCY")

echo "concurrent = $CONCURRENCY" > .gitlab-runner/config.toml

gitlab-runner register "${runner_args[@]}"

exec gitlab-runner run
