FROM docker.io/openresty/openresty:1.17.8.2-3-alpine-fat

RUN mkdir /var/log/nginx /tls

RUN apk add --no-cache \
  gcc \
  git \
  openssl \
  openssl-dev
RUN luarocks install lua-resty-openidc

COPY contrib/confd-0.16.0-linux-amd64 /usr/local/bin/confd
COPY contrib/dumb-init_1.2.2_amd64 /usr/local/bin/dumb-init
COPY entrypoint.sh /entrypoint.sh
COPY confd/ /etc/confd/
COPY dirlist.xslt /usr/local/openresty/nginx/xslt/dirlist.xslt

RUN chmod +x \
        /entrypoint.sh \
        /usr/local/bin/confd \
        /usr/local/bin/dumb-init

EXPOSE 80 443
VOLUME /var/www/html

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/entrypoint.sh"]
