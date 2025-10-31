#!/bin/bash

set -e

if [ -z "$SSH_KEY" ]; then
    echo "Error: missing SSH_KEY variable" 1>&2
    exit 1
fi

cd /home/gitlab-runner
mkdir -p .ssh
touch .ssh/id_rsa .ssh/id_rsa.pub
chown gitlab-runner:gitlab-runner .ssh .ssh/id_rsa .ssh/id_rsa.pub
chmod go-rwx .ssh .ssh/id_rsa
echo "$SSH_KEY" > .ssh/id_rsa
ssh-keygen -f .ssh/id_rsa -y > .ssh/id_rsa.pub

while true; do
    sleep 300
done
