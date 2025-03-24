#!/bin/sh

# This directory won't exist the first time this container starts.
# ssl_db is part of /var/cache/squid which should be mounted on some
# persistent storage, as it contains Squid's cache.
if [ ! -d /var/spool/squid/ssl_db ]; then
  # Creates the generated SSL Certs cache.
  /usr/local/squid/libexec/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
fi

# Initialize cache
/usr/local/squid/sbin/squid -f /etc/squid/squid.conf -Nz

#run squid
exec /usr/local/squid/sbin/squid -f /etc/squid/squid.conf -NYCd 1

