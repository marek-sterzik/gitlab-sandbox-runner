FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
        curl \
        git \
        openssh-client \
	    && \
    curl -s https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends gitlab-runner && \
	rm -rf /var/lib/apt/lists/* /tmp/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER gitlab-runner
WORKDIR /home/gitlab-runner

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
