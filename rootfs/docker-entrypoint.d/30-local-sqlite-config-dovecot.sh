#!/bin/sh

# https://doc.dovecot.org/configuration_manual/authentication/proxies/#example-password-forwarding-sql-configuration

# Create sqlite config if it does not exist
if [ ! -f /etc/dovecot/dovecot-sqlite.conf.ext ]; then
	cat > /etc/dovecot/dovecot-sqlite.conf.ext << EOF
driver = sqlite
connect = /var/lib/dovecot/sqlite/dct.db
password_query = SELECT NULL AS password, "yes" as starttls, 'Y' as nopassword, host, destuser, 'Y' AS proxy FROM proxy WHERE user = '%u'
EOF
fi
