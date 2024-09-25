#!/bin/bash

exec /docker-entrypoint.sh "$@" & NGINX_PID=$! && export NGINX_PID && ./scripts/certbot-setup.sh && cron
wait -n $NGINX_PID
