#!/bin/sh

if [ -n "${CERT_CN}" ]; then
	[ -L /etc/letsencrypt/live/"${CERT_CN}"/fullchain.pem ] && [ ! -L /etc/ssl/dovecot/"${CERT_CN}".pem ] && ln -s /etc/letsencrypt/live/"${CERT_CN}"/fullchain.pem /etc/ssl/dovecot/"${CERT_CN}".pem
	[ -L /etc/letsencrypt/live/"${CERT_CN}"/privkey.pem ] && [ ! -L /etc/ssl/dovecot/"${CERT_CN}".key ] && ln -s /etc/letsencrypt/live/"${CERT_CN}"/privkey.pem /etc/ssl/dovecot/"${CERT_CN}".key
	if [ -L /etc/ssl/dovecot/"${CERT_CN}".key ] && [ -L /etc/ssl/dovecot/"${CERT_CN}".pem ]; then
		# Create a sane local.conf
		cat >> /etc/dovecot/local.conf << EOF
# Adjust certificates to our needs
ssl_cert = </etc/ssl/dovecot/${CERT_CN}.pem
ssl_key = </etc/ssl/dovecot/${CERT_CN}.key
EOF
	fi
fi
