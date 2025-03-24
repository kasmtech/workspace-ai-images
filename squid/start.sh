#!/usr/bin/env bash
set -ex

PROXY_HOSTNAME=${PROXY_HOSTNAME:-proxy_cache}

function gen-cert() {
    if [ ! -f ca.pem ]; then
        openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes \
            -x509 -keyout privkey.pem -out ca.pem \
            -subj '/CN=${PROXY_HOSTNAME}/O=NULL/C=AU'
        chown proxy:proxy privkey.pem
        chmod 600 privkey.pem
        apt-get install -y ca-certificates
        cp ca.pem /usr/local/share/ca-certificates/proxy_cache.crt
        echo '${PROXY_HOSTNAME}.pem' | tee -a /etc/ca-certificates.conf
        update-ca-certificates
        echo "Certificate generated for '${PROXY_HOSTNAME}' and installed into trusted certificates."
    else
        echo "Reusing existing certificate"
    fi
    openssl x509 -sha1 -in ca.pem -noout -fingerprint
}

gen-cert

if [ ! -d "/var/spool/squid" ]; then
  mkdir -p /var/spool/squid
  chown proxy:proxy /var/spool/squid
  echo "Cache directory created"
fi

if [ ! -d "/var/log/squid" ]; then
  mkdir -p /var/log/squid
  chown proxy:proxy /var/log/squid
  echo "Log directory created"
fi

