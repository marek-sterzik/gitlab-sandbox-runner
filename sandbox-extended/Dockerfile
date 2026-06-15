FROM sandboxrunner/sandbox:latest

RUN apt-get update && \
    apt-get install -y iproute2 php-cli php-zip php-curl curl unzip 7zip wget python3 python3-yaml python3-schema && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsLS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN wget -O /usr/local/bin/mikdim https://github.com/mikenopa-cz/mikdim/raw/refs/heads/master/mikdim && ln -s mikdim /usr/local/bin/mikdeb && chmod +x /usr/local/bin/mikdim

COPY bin/ /usr/local/bin/
