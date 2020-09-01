#!/usr/bin/env sh
echo "-----"
echo "Generating Configuration Files"
confd -onetime -backend env -log-level debug || exit 1
echo "-----"

if [ -f /tls/tls.crt ]; then
  echo "Using supplied certificate"
  echo "-----"
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
fi

if [[ -x "/usr/local/bin/make-proxy-dirs.sh" ]]
then
  echo "Creating proxy and redirect directories"
  /usr/local/bin/make-proxy-dirs.sh
  echo "-----"
fi


echo "Checking Syntax"
cat /etc/nginx/conf.d/default.conf
${*:-/usr/local/openresty/nginx/sbin/nginx -t} || exit 1
echo "-----"

echo ${*:-/usr/local/openresty/nginx/sbin/nginx -g "daemon off;"}
exec ${*:-/usr/local/openresty/nginx/sbin/nginx -g "daemon off;"} || exit 1
