#!/bin/sh

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
if [ ! -d /var/lib/dovecot/sqlite ]; then
	mkdir -p /var/lib/dovecot/sqlite
fi
if [ ! -f /etc/dovecot/dovecot-sqlite.conf.ext ]; then
	cat > /etc/dovecot/dovecot-sqlite.conf.ext << EOF
driver = sqlite
connect = /var/lib/dovecot/sqlite/dct.db
password_query = SELECT NULL AS password, 'Y' as nopassword, host, destuser, 'Y' AS proxy FROM proxy WHERE user = '%u'
EOF
fi