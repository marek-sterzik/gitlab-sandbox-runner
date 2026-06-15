FROM debian:bookworm

COPY create-fake-gitlab-runner-helper-images /tmp/create-fake-gitlab-runner-helper-images

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		iptables \
		openssl \
		pigz \
		xz-utils \
        curl \
        git \
        git-lfs \
        openssh-server \
        sudo \
	    && \
    mkdir -p /etc/init.d && \
    curl -s https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    /tmp/create-fake-gitlab-runner-helper-images && \
    apt-get install -y --no-install-recommends gitlab-runner && \
	rm -rf /var/lib/apt/lists/* /etc/ssh/ssh_host_* /etc/ssh/sshd_config.d && \
    curl -L https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64 > /usr/bin/regctl.bin && \
    chmod +x /usr/bin/regctl.bin

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir -p /certs /certs/client /var/lib/docker /run/sshd && chmod 1777 /certs /certs/client

COPY --from=docker:dind /usr/local/bin/ /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/ /usr/local/libexec/
RUN mv /usr/local/bin/docker /usr/local/bin/docker.bin

COPY bin/ /usr/local/bin/
COPY sshd_config /etc/ssh/sshd_config
COPY ssh-host-keys/ /etc/ssh/

RUN groupadd -r -g 984 docker && \
    useradd -s /bin/bash -m sandbox -G docker && \
    mkdir /home/sandbox/.ssh && \
    chown sandbox:sandbox /home/sandbox/.ssh && \
    chmod 0700 /home/sandbox/.ssh && \
    chmod 0600 /etc/ssh/ssh_host_* && \
    ln -s docker.sh /usr/local/bin/docker && \
    rm -f /home/sandbox/.bashrc /home/sandbox/.bash_logout /home/sandbox/.profile && \
    echo "ALL   ALL=(root) NOPASSWD:/usr/local/bin/pre-get-sources" >> etc/sudoers.d/pre-get-sources

EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
CMD []
