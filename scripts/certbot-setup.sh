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
certbot --non-interactive --agree-tos -m $CERTBOT_EMAIL --nginx --domains $DOMAINS $CERTBOT_OPTIONS
exit $?