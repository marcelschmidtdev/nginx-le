# nginx-le
Docker image for Nginx with Let's Encrypt

## How to use?
This Docker image runs latest Nginx together with Let's Encrypt Certbot. It will configure Certbot based on environment variables and automatically request certificates for specified domains. Once configured it uses Cron to renew all certificates.

Mount your folder containing `*.conf` files to `/etc/nginx/available-conf.d`. Configs will be enabled after Certbot setup is done and certificates were acquired.

**Required variables:**
  * `CERTBOT_EMAIL`
  * `DOMAINS` (comma separated list for alias domains, semicolon separated list for independent certificates)
    * E.g. `a.example.com,b.example.com;example.com` 
    * creates 2 different certificates where in the first one `b.example.com` is an alias domain of `a.example.com`

**DNS Plugins:**
  * `DNS` e.g. `cloudflare`
  * `DNS_CREDENTIALS` path to secret credential file for DNS provider
  * `DNS_PROPAGATION` (optional, default 60 seconds) 

**Optional variables:**
  * `CERT_EXPORT`
  * `CERTBOT_OPTIONS` additional Certbot options, e.g. `--reuse-key`

## Export certificates:

If you want to export the received certificates (e.g. in case you want to reuse them in a different environment) you can do the following:
1. Mount a volume or folder to `/le_export`
2. Define `CERT_EXPORT` (comma separated list) for the domains you want to export
