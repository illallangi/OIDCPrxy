FROM docker.io/openresty/openresty:1.15.8.3-alpine-fat

RUN mkdir /var/log/nginx /tls

RUN apk add --no-cache \
  gcc \
  git \
  openssl \
  openssl-dev
RUN luarocks install lua-resty-openidc

ENV PROXY_ROOT_LOCATION=/

COPY contrib/confd-0.16.0-linux-amd64 /usr/local/bin/confd
COPY contrib/dumb-init_1.2.2_amd64 /usr/local/bin/dumb-init
COPY entrypoint.sh /entrypoint.sh
COPY confd/ /etc/confd/

RUN chmod +x \
        /entrypoint.sh \
        /usr/local/bin/confd \
        /usr/local/bin/dumb-init

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/entrypoint.sh"]
