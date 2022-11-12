FROM alpine:3.16.2

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH
ARG DOVECOT_PACKAGE_VERSION=2.3.19.1-r0
ARG SOCAT_PACKAGE_VERSION=1.7.4.3-r0

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
# Disable Dovecot TLS during installation to prevent key from being pregenerated
RUN mkdir -p /etc/dovecot && echo "ssl = no" > /etc/dovecot/local.conf && \
    apk --no-cache update && apk --no-cache upgrade && \
    # Install needed packages
    apk add --update --no-cache \
        dovecot=$DOVECOT_PACKAGE_VERSION \
        dovecot-lmtpd=$DOVECOT_PACKAGE_VERSION \
        dovecot-pigeonhole-plugin=$DOVECOT_PACKAGE_VERSION \
        dovecot-pop3d=$DOVECOT_PACKAGE_VERSION \
        dovecot-sqlite=$DOVECOT_PACKAGE_VERSION \
        socat=$SOCAT_PACKAGE_VERSION && \
    rm /etc/dovecot/local.conf && \
    find /var/cache/apk /tmp -mindepth 1 -delete && \
    # create needed directories
    mkdir -p /run/dovecot/ && \
    echo -e "log_path = /dev/stderr\ninfo_log_path = /dev/stdout\ndebug_log_path = /dev/stdout" > /etc/dovecot/conf.d/95-local-log.conf
    # forward request and error logs to docker log collector
    # See https://github.com/moby/moby/issues/19616
    #ln -sf /proc/1/fd/1 /var/log/dovecot/access.log && \
    #ln -sf /proc/1/fd/1 /var/log/dovecot/error.log

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

CMD ["/usr/local/bin/dovecot-wrapper"]
