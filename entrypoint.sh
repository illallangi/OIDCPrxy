#!/usr/bin/env sh

confd -onetime -backend env -log-level debug || exit 1
cat /etc/nginx/conf.d/default.conf

if [ -f /tls/tls.crt ]; then
  echo "Using supplied certificate"
else
  openssl \
    req \
      -x509 \
      -sha256 \
      -newkey rsa:4096 \
      -keyout key.pem \
      -out cert.pem \
      -days 365 \
      -nodes \
      -subj "/C=AU/ST=Victoria/L=Melbourne/O=Illallangi Enterprises/OU=OIDC Proxy/CN=${FQDN}" \
      -keyout /tls/tls.key \
      -out    /tls/tls.crt \
    || exit 1
  echo "Generated self signed certificate"
fi

exec ${*:-/usr/local/openresty/nginx/sbin/nginx -g "daemon off;"} || exit 1
