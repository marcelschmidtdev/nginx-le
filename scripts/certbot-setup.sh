#!/bin/bash

set -e

entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

ME=$(basename "$0")

set +e

certbot show_account > /dev/null 2>&1

if [ $? -eq 0 ]; then
  entrypoint_log "$ME: Found existing account! Skipping configuration..."

  if [ "$(ls /etc/letsencrypt/renewal)" ]; then
    entrypoint_log "$ME: Found configured domains! Attempting renewal..."
    certbot renew --nginx
    exit $?
  fi
  exit 0
fi

set -e

if [[ -z $CERTBOT_EMAIL ]]; then
  entrypoint_log "$ME: CERTBOT_EMAIL environment variable undefined. Aborting!"
  exit 1
fi

if [[ -z $DOMAINS ]]; then
  entrypoint_log "$ME: DOMAINS environment variable undefined. At least one domain needs to be defined!"
  exit 1
fi

entrypoint_log "$ME: Creating certbot renewal-hooks..."
ln -sf /scripts/certbot-export.sh /etc/letsencrypt/renewal-hooks/post/certbot-export.sh

entrypoint_log "$ME: Creating new certbot account!"

dns_options=""
web_server="--nginx"

if [[ -n $DNS ]]; then
  entrypoint_log "$ME: Using $DNS DNS plugin."

  if [[ -z $DNS_CREDENTIALS ]]; then
    entrypoint_log "$ME: DNS_CREDENTIALS environment variable undefined. Aborting!"
    exit 1  
  fi

  web_server=""
  dns_options="--dns-${DNS} --dns-${DNS}-credentials $DNS_CREDENTIALS --dns-${DNS}-propagation-seconds ${DNS_PROPAGATION:-60}"
fi

IFS=';' read -r -a array <<< "$DOMAINS"
for domain in "${array[@]}"
do
  certbot certonly $dns_options --non-interactive --agree-tos -m $CERTBOT_EMAIL $web_server --domains $domain $CERTBOT_OPTIONS
  if [ $? -gt 0 ]; then
    exit $?
  fi
done

exit $?