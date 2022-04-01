FROM caddy:2.4.6

RUN apk add --no-cache nss-tools

# In production, pack config and content in to the image.
# In development, write over them with volumes in docker-compose
COPY Caddyfile /etc/caddy/Caddyfile
COPY content /srv
