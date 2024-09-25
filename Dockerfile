FROM nginx:latest
LABEL org.opencontainers.image.authors="Marcel Schmidt"

ENV CERTBOT_DNS_AUTHENTICATORS \
    cloudflare

RUN set -ex \ 
 && apt update \
 && apt install --no-install-recommends --no-install-suggests -y cron logrotate python3 python3-venv libaugeas0 \
 && python3 -m venv /opt/certbot/ \
 && /opt/certbot/bin/pip install --upgrade pip \
 && /opt/certbot/bin/pip install certbot certbot-nginx $(echo $CERTBOT_DNS_AUTHENTICATORS | sed 's/\(^\| \)/\1certbot-dns-/g')\
 && ln -s /opt/certbot/bin/certbot /usr/bin/certbot \
 && echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab > /dev/null \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/.cache \
 && mkdir -p /var/www/letsencrypt \
 && mkdir -p /etc/nginx/available-conf.d \
 && mv /etc/nginx/conf.d/* /etc/nginx/available-conf.d \
 && sed -i 's/conf.d/available-conf.d/' /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh \
 && sed -i 's/grep $DEFAULT_CONF_FILE/grep default.conf/g' /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh \
 && chown www-data:www-data -R /var/www

COPY ./scripts /scripts
COPY ./docker-entrypoint.d/*.sh /docker-entrypoint.d

RUN chmod -R +x /scripts \
 && chmod -R +x /docker-entrypoint.d

VOLUME /etc/letsencrypt
 
# Parent nginx image already exposes 80
EXPOSE 443

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
