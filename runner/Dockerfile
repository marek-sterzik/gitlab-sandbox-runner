FROM debian:trixie

COPY create-fake-gitlab-runner-helper-images /tmp/create-fake-gitlab-runner-helper-images

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
        curl \
        git \
        openssh-client \
	    && \
    mkdir -p /etc/init.d && \
    curl -s https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    /tmp/create-fake-gitlab-runner-helper-images && \
    apt-get install -y --no-install-recommends gitlab-runner && \
	rm -rf /var/lib/apt/lists/* /tmp/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY user-entrypoint.sh /usr/local/bin/user-entrypoint.sh

RUN mkdir /persistent 

WORKDIR /home/gitlab-runner

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
