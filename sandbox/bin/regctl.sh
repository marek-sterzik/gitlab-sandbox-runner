#!/bin/bash

set -e

source docker.env

exec regctl.bin "$@"
