# checkov:skip=CKV_DOCKER_2: no healthcheck (yet)
# checkov:skip=CKV_DOCKER_3: no user (yet)
# syntax = docker/dockerfile:1
# requires DOCKER_BUILDKIT=1 set when running docker build
FROM alpine:3.21.0

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH
ARG DOVECOT_PACKAGE_VERSION=2.3.21.1-r0
ARG SOCAT_PACKAGE_VERSION=1.8.0.0-r0

# See http://label-schema.org/rc1/ and https://microbadger.com/labels
LABEL maintainer="Jan Wagner <waja@cyconet.org>" \
    org.label-schema.name="Dovecot IMAP server" \
    org.label-schema.description="Alpine Linux container with installed dovecot package" \
    org.label-schema.vendor="Cyconet" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE:-unknown}" \
    org.label-schema.version="${BUILD_VERSION:-unknown}" \
    org.label-schema.vcs-url="${VCS_URL:-unknown}" \
    org.label-schema.vcs-ref="${VCS_REF:-unknown}" \
    org.label-schema.vcs-branch="${VCS_BRANCH:-unknown}" \
    org.opencontainers.image.source="https://github.com/waja/docker-dovecot"

# hadolint ignore=DL3017,DL3018
RUN --mount=type=cache,target=/var/log \
    --mount=type=cache,target=/var/cache \
    --mount=type=tmpfs,target=/tmp \
    <<EOF
    # Disable Dovecot TLS during installation to prevent key from being pregenerated
    mkdir -p /etc/dovecot && echo "ssl = no" > /etc/dovecot/local.conf
    apk --no-cache update && apk --no-cache upgrade
    # Install needed packages
    apk add --update --no-cache \
        dovecot=$DOVECOT_PACKAGE_VERSION \
        dovecot-lmtpd=$DOVECOT_PACKAGE_VERSION \
        dovecot-pigeonhole-plugin=$DOVECOT_PACKAGE_VERSION \
        dovecot-pop3d=$DOVECOT_PACKAGE_VERSION \
        dovecot-sqlite=$DOVECOT_PACKAGE_VERSION \
       socat=$SOCAT_PACKAGE_VERSION
    # remove (possible) shipped dovecot local config
    rm -f /etc/dovecot/local.conf
    # this shouldn't needed, cause we cache /var/cache
    find /var/cache/apk /tmp -mindepth 1 -delete
    # create needed directories
    mkdir -p /run/dovecot/
EOF

# Add wrapper script that will generate the TLS configuration on startup
COPY rootfs /

#   24: LMTP
#  110: POP3 (StartTLS)
#  143: IMAP4 (StartTLS)
#  993: IMAP (SSL, deprecated)
#  995: POP3 (SSL, deprecated)
# 4190: ManageSieve (StartTLS)
EXPOSE 24 110 143 993 995 4190

STOPSIGNAL SIGTERM

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["dovecot", "-F"]
