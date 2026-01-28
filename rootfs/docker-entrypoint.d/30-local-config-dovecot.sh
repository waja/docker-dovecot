#!/bin/sh

# https://doc.dovecot.org/configuration_manual/authentication/proxies/#example-password-forwarding-sql-configuration

# Create a sane local.conf
if [ ! -f /etc/dovecot/local.conf ]; then
	cat >/etc/dovecot/local.conf <<EOF
# If you are not moving mailboxes between hosts on a daily basis you can
# use authentication cache pretty safely.
auth_cache_size = 4096

auth_mechanisms = plain
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sqlite.conf.ext
}

#auth_policy_request_attributes = login=%{requested_username} pwhash=%{hashed_password} remote=%{rip} device_id=%{client_id} protocol=%s
protocols = imap lmtp sieve pop3
#ssl = yes
#ssl_cipher_list = ALL:!kRSA:!SRP:!kDHd:!DSS:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK:!RC4:!ADH:!LOW@STRENGTH # codespell:ignore anull
#ssl_min_protocol = TLSv1
#ssl_prefer_server_ciphers = no
EOF
fi
