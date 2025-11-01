#!/bin/bash

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

if [ -n "$AUTHORIZED_KEYS" ]; then
    echo "$AUTHORIZED_KEYS" > /home/sandbox/.ssh/authorized_keys
    chown sandbox:sandbox /home/sandbox/.ssh/authorized_keys
    chmod 0600 /home/sandbox/.ssh/authorized_keys
else
    rm -f /home/sandbox/.ssh/authorized_keys
fi

DOCKER_CI_ISOLATION="`load_bool "$DOCKER_CI_ISOLATION" "true"`"
if [ -z "$DOCKER_CI_ISOLATION" ]; then
    echo "Error: invalid value of DOCKER_CI_ISOLATION variable (<bool>)" 1>&2
    exit 1
fi

if [ "$DOCKER_CI_ISOLATION" = 1 ]; then
    rm -f /usr/local/bin/docker
    ln -s docker.sh /usr/local/bin/docker
else
    rm -f /usr/local/bin/docker
    ln -s docker.bin /usr/local/bin/docker
fi

/usr/sbin/sshd

exec dockerd-entrypoint.sh "$@"
