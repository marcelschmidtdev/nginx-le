FROM nginx:latest
LABEL org.opencontainers.image.authors="Marcel Schmidt"

RUN set -ex \ 
 && apt update \
 && apt install --no-install-recommends --no-install-suggests -y cron python3 python3-venv libaugeas0 \
 && python3 -m venv /opt/certbot/ \
 && /opt/certbot/bin/pip install --upgrade pip \
 && /opt/certbot/bin/pip install certbot certbot-nginx \
 && ln -s /opt/certbot/bin/certbot /usr/bin/certbot \
 && echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab > /dev/null \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/.cache \
 && mkdir -p /var/www/letsencrypt \
 && chown www-data:www-data -R /var/www

COPY ./scripts /scripts
RUN chmod -R +x /scripts

VOLUME /etc/letsencrypt
 
# Parent nginx image already exposes 80
EXPOSE 443

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
