#!/bin/sh

set -e

entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

ME=$(basename "$0")

if [ -n "$(ls /etc/nginx/conf.d/*.conf 2> /dev/null)" ]; then
  entrypoint_log "$ME: info: cleanup conf.d"
  rm /etc/nginx/conf.d/*.conf
fi

exit 0