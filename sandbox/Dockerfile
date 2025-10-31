FROM debian:bookworm

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
	    && \
	rm -rf /var/lib/apt/lists/* /etc/ssh/ssh_host_* /etc/ssh/sshd_config.d

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir -p /certs /certs/client /var/lib/docker /run/sshd && chmod 1777 /certs /certs/client

COPY --from=docker:dind /usr/local/bin/ /usr/local/bin/

COPY sshd_config /etc/ssh/sshd_config
COPY ssh-host-keys/ /etc/ssh/
COPY entrypoint.sh /usr/local/bin/

RUN groupadd -r -g 984 docker && \
    useradd -s /bin/bash -m sandbox -G docker && \
    mkdir /home/sandbox/.ssh && \
    chown sandbox:sandbox /home/sandbox/.ssh && \
    chmod 0700 /home/sandbox/.ssh && \
    chmod 0600 /etc/ssh/ssh_host_* && \
    rm -f /home/sandbox/.bashrc /home/sandbox/.bash_logout /home/sandbox/.profile

EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
CMD []
