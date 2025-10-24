#!/bin/bash

if [ -n "$AUTHORIZED_KEYS" ]; then
    echo "$AUTHORIZED_KEYS" > /home/sandbox/.ssh/authorized_keys
    chown sandbox:sandbox /home/sandbox/.ssh/authorized_keys
    chmod 0600 /home/sandbox/.ssh/authorized_keys
else
    rm -f /home/sandbox/.ssh/authorized_keys
fi

/usr/sbin/sshd

exec dockerd-entrypoint.sh "$@"
