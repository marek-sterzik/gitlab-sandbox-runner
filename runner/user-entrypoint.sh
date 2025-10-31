#!/bin/bash

set -e

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

if [ -z "$SSH_KEY" ]; then
    echo "Error: missing SSH_KEY variable" 1>&2
    exit 1
fi

cd /home/gitlab-runner

create_user_env
install_ssh_key "$SSH_KEY"

gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --token "$GITLAB_TOKEN" \
    --executor "ssh" \
    --name "$RUNNER_NAME" \
    --ssh-user "sandbox" \
    --ssh-host "sandbox" \
    --ssh-port "22" \
    --ssh-password "" \
    --ssh-identity-file "/home/gitlab-runner/.ssh/id_rsa" \
    --ssh-disable-strict-host-key-checking true

exec gitlab-runner run
