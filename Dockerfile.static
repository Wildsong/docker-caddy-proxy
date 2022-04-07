FROM caddy:2.4.6

RUN apk add --no-cache ca-certificates curl tzdata; \
    rm -rf /var/cache/apk/*;

WORKDIR /srv
COPY Caddyfile.static Caddyfile
COPY content/* ./

ENTRYPOINT [ "/usr/bin/caddy" ]
CMD [ "run" ]