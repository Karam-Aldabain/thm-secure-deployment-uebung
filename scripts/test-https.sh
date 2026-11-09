#!/usr/bin/env bash
set -euo pipefail
docker build -t thm-https:ci ./https
mkdir -p https/certs
docker run --rm --mount "type=bind,src=$PWD/https/certs,dst=/certs" \
  thm-https:ci openssl req -x509 -nodes -newkey rsa:3072 \
  -sha256 -days 365 -keyout /certs/thm.key -out /certs/thm.crt \
  -subj "/CN=thm.de" -addext "subjectAltName=DNS:thm.de"
docker run -d --name https-test -p 127.0.0.1:8443:443 \
  --mount "type=bind,src=$PWD/https/certs,dst=/etc/nginx/certs,readonly" \
  thm-https:ci
trap 'docker logs https-test; docker rm -f https-test' EXIT
docker exec https-test nginx -t
docker exec https-test openssl x509 -in /etc/nginx/certs/thm.crt \
  -noout -checkhost thm.de
curl --fail --silent --show-error --retry 15 --retry-connrefused \
  --retry-delay 2 --noproxy '*' --resolve thm.de:8443:127.0.0.1 \
  --cacert https/certs/thm.crt https://thm.de:8443/ -o /tmp/https.txt
printf 'HTTPS fuer thm.de funktioniert.\n' > /tmp/expected-https.txt
cmp /tmp/expected-https.txt /tmp/https.txt
cat /tmp/https.txt
