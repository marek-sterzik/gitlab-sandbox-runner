#!/bin/bash

set -e

mkdir -p /persistent/gitlab-runner
chown gitlab-runner:gitlab-runner /persistent/gitlab-runner

exec su gitlab-runner -c "user-entrypoint.sh" "$@"
