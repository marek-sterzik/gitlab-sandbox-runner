# Sandbox runner

This repository contains a solution for a full-featured docker-enabled dockerised gitlab runner.

Features:

* possibility to run build commands utilizing docker
* builds are completely isolated from the host and run in a docker container
* easy to use solution with two containers (runner and sandbox)
* full support for concurrent builds including concurrent docker usage

## Overview

The solution consists of two standalone containers:

1. `runner` - the gitlab runner itself
2. `sandbox` - is the sandbox environment executing the CI tasks

Both container images are intended to cooperate, but it is also possible to use both images
separately.

The `runner` image is communicating with a gitlab instance and listening for CI jobs to be executed.

The `sandbox` image is acting as an executor of the gitlab runner. The `sandbox` image exposes
the ssh service so that the `runner` may connect to it.

The `sandbox` image contains a docker-in-docker (dind) solution and therefore it needs to be executed
in a privileged mode. There are two options:

1. (insecure) `sandbox` is being run in the privileged mode
2. (secure) `sandbox` is being executed using the [sysbox-runc](https://github.com/nestybox/sysbox/) runtime

While one cannot guarantee, that the executing user in the `sandbox` may become a root (every user being
allowed to run docker containers may easily become root) running `sandbox` in the insecure privileged mode
means, that the sandbox root is also the system root and therefore scripts run in the `sandbox` may
damage the host system.

On the other hand, the [sysbox-runc](https://github.com/nestybox/sysbox/) runtime should disallow any damages
to the host system. The sandbox container still may be damaged, but any damage should not leave the sandbox
container.

The file [docker-compose-example.yaml](docker-compose-example.yaml) contains an example of a docker
compose configuration of both containers orchestrated. It is just necessary to fill the environment
variables `GITLAB_URL` and `GITLAB_TOKEN`.

## Used images

### runner

The `runner` image runs the gitlab runner itself.

Environment variables:

* `GITLAB_URL` - url of the gitlab instance
* `GITLAB_TOKEN` - the gitlab runner authorization token
* `SSH_CONNECT` - ssh connection in the form `<username>@<host>[:<port>]`
* `SSH_KEY` - the private ssh key authenticating the ssh connection
* `SSH_PASSWORD` (optional) - the ssh password authenticating the ssh connection
* `SANDBOX_LOAD_GITLAB_ENV` (optional) - set to `false` if you don't want to disable invoking the gitlab specific build hook in the sandbox environment
  (build hook is necessary for full docker concurency), default `true`
* `CONCURRENCY` (optional) - number of concurrently invoked CI tasks, default `1`

The container with the `runner` image should make the path `/persistent` persistent so that the runner id is persisted.

### sandbox

The `sandbox` image runs the sandbox with dind. It is strongly recommented to run the container with this image
using [sysbox-runc](https://github.com/nestybox/sysbox/).

Environment variables:

* `AUTHORIZED_KEYS` - ssh keys being authorized in the format of the `~/.ssh/authorized_keys` file

Properties of the `sandbox` container:

* The container exposes the port 22 where the standard ssh server is listening.
* The container ssh server uses hardcoded ssh keys and therefore it is strongly recommented.
  to use this ssh connection only on trusted networks.
* There is a special command `gitlab-load-env` acting as the build hook for the `runner` image.
* Even if the user executing commands would become a root, sensitive data cannot
  leak. They are just no sensitive data inside of the container at all.
* `sandbox` is a debian based image so other required packages may be easily installed and the
  basic sandbox image may be extended by specific custom needs.

