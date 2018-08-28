FROM adaptorel/abiosoft-caddy:builder as builder

ARG version="0.10.10"
ARG plugins="cors"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

# Dist image
FROM alpine:3.8

# install deps
RUN apk add --no-cache --no-progress curl tini ca-certificates

# copy caddy binary
COPY --from=builder /install/caddy /usr/bin/caddy

# list plugins
RUN /usr/bin/caddy -plugins

# static files volume
VOLUME ["/www"]
WORKDIR /www

COPY Caddyfile /etc/caddy/Caddyfile

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["caddy", "-agree", "--conf", "/etc/caddy/Caddyfile"]
