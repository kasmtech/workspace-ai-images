# About This Image

This Image contains a Squid proxy built by Kasm that includes SSL Bumping capabilities and is designed for caching HTTP assets such as pip packages, AI models, zip files, etc.

The intended use cases are as follows:
* Support Kasm Workspace users that are downloading the same set of files being able to download them faster because their HTTP resources can be cached on the Kasm Agent server (Docker host)
* Support Kasm Workspace users working in air-gapped environments where administrators can pre-cache certain HTTP resources for their users. 

# Setup

* Run the following Bash script on the Agent server. It will generate a self-signed SSL certificate and install it into the system trust store as well as creating directories for Squid cache and logs on the host:
```shell
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
```

* Start the squid proxy, the following Docker-compose file provides an example. Please update paths to `ca.pem` and `privkey.pem` that were generated in the first step.
```yaml
version: '3'
services:
  proxy_cache:
    container_name: proxy_cache
    image: "TODO"
    ports:
      - "3128:3128"
      - "3129:3129"
    environment:
      - TZ=UTC
    network_mode: "kasm_default_network"
    networks:
      - kasm_default_network
    volumes:
      - ./ca.pem:/etc/squid/ssl_cert/ca.pem:ro
      - ./privkey.pem:/etc/squid/ssl_cert/privkey.pem:ro
      - /var/spool/squid:/var/spool/squid:rw
      - /var/log/squid:/var/log/squid:rw
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "20"
networks:
  kasm_default_network:
    external: true
```
* Kasm's AI images support automatic pass-through of the host trust store into Kasm workspaces. Add the following environment variables to the `Docker Run Config Override` to enable use of this proxy within the container:
```json
{
  "environment": {
    "http_proxy": "http://proxy_cache:3128",
    "https_proxy": "http://proxy_cache:3128"
  }
}
```
* Also ensure the host certificates are mapped into the container by using a Volume Mapping:
```json
{
  "/usr/local/share/ca-certificates": {
    "bind": "/usr/local/share/ca-certificates",
    "mode": "ro",
    "uid": 1000,
    "gid": 1000,
    "required": true,
    "skip_check": false
  },
  "/var/spool/python_versions/": {
    "bind": "/var/spool/python_versions/",
    "mode": "ro",
    "uid": 1000,
    "gid": 1000,
    "required": true,
    "skip_check": false
  }
}
```

# Customizing Squid configuration
The default [`squid.conf`](default_squid.conf) can be overridden by mapping an override into the location `/etc/squid/squid.conf`