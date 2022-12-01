#!/bin/sh

# https://doc.dovecot.org/configuration_manual/authentication/proxies/#example-password-forwarding-sql-configuration

# Create a sane local.conf
if [ ! -f /etc/dovecot/local.conf ]; then
	cat > /etc/dovecot/local.conf << EOF
# If you are not moving mailboxes between hosts on a daily basis you can
# use authentication cache pretty safely.
auth_cache_size = 4096

auth_mechanisms = plain
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sqlite.conf.ext
}
EOF
fi
