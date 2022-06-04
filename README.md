# docker-caddy-proxy

This is a reverse proxy configuration based on
[homeall/caddy-reverse-proxy-cloudflare](https://github.com/homeall/caddy-reverse-proxy-cloudflare) which is in turn built on 
[lucaslorentz/caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy).
Many thanks to homeall and to lucaslorentz for their excellent work.

I am using Cloudflare for my domains, so Caddy makes the most sense.
By using a Cloudflare API token, the proxy can communicate directly
with their DNS to activate Let's Encrypt certificates. It is an
elegant approach and even works behind a firewall.

## What this project is for

I have a bunch of use cases I need to support, that I have already
conquered with the nginx proxy. I need to put together tests to see
what it would be like using Caddy instead.

I met the basic requirement, which is to reverse proxy several
services that were already running behind a swag proxy.

I have a single caddy instance running to serve static content
but have not worked out all the path requirements I want yet.

## Use Docker to run a simple HTTP server.

Just to kick things off, this is a Caddy HTTP server.

   docker run -p 80:80 -v caddy_data:/data caddy

## Prerequisites

Copy sample.env to .env and edit.

Create the swarm-scoped network (works for compose or swarm)

```bash
docker network create -d overlay proxy
```

Generate an API token at Cloudflare.
The token needs Zone-Zone-Read and Zone-DNS-Edit.

Create the volume for certificates and a link.
The link makes it easier to work with the certificates from other containers like svelte-template-app.

```bash
docker-compose up -d
docker run -ti --rm \
  -v proxy_certs:/db
     alpine sh -c 'ln -s /db/caddy/certificates/acme-v02.api.letsencrypt.org-directory/ certificates'
```

## Permissions

I decided to borrow the certificates generated here to test a Svelte app (svelte-template-app) that
needed authentication, so I wanted it to use SSL. That means it needed to be able to read the certificates
that Caddy generates.

I changed this project to drop root permissions when it runs Caddy. To do this I had to change permissions
on the caddy_data and config folders. I created a user "caddy" and put it in the "docker" group so that it
could read the unix docker socket. Then I gave the volume group write and set its group to "docker".
I moved the config folder from /config, and 
it does not need to be in a volume, so it's in /home/caddy/ now.

## Run

The usual

   docker-compose up -d
   
### Start in SWARM mode, which I don't do currently.

    docker-compose -f docker-swarm.yml config

But wait! "Deploy" ignores .env files. So this fails.

   docker stack deploy -c docker-swarm.yml caddy

But this works.

   docker stack deploy <(docker-compose -f docker-swarm.yml config) caddy

   docker stack services
   
Stop

   docker stack ls
   docker stack remove caddy

### How to reload just the proxy

This is the clumsy way.

    docker exec caddy_caddy_1 caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile

This is more elegant. Not sure if it works. TODO :-)

    docker exec caddy_caddy_1 curl http://localhost:2019/reload/

## The tests

Solve these problems to determine if it is suitable.

* Support more than one FQDN (virtual hosts)
* Support static content on different paths
* Reverse proxy many services, on different virtual hosts
* Can it run in SWARM mode? This would allow me to run the proxy on one machine and have services on others.
For example, I could put webforms.co.clatsop.or.us on cc-giscache and put the actual Flask docker on cc-testmaps.
This is not essential but would be great to separate development from production.

### Real life example from cc-giscache

Read fast I will be deleting this section soon.

* https://giscache.co.clatsop.or.us/   reverse for mapproxy service
* https://giscache.co.clatsop.or.us/PDF  static content for a folder out on the network fileserver
* https://giscache.co.clatsop.or.us/photoshow/  reverse for photoshow service
* https://giscache.co.clatsop.or.us/photo/  reverse for property_api Flask service
* https://capacity.co.clatsop.or.us/   reverse for an nginx instance service static content
* https://webforms.co.clatsop.or.us/   reverse for a flask app

## Adding a new service

The service has to have labels defined in its docker-compose.yml file
to tell Caddy about it. Here is my Home Assistant for example,

```bash
   labels:
      caddy: homeassistant.${DOMAIN}
      caddy.reverse_proxy: "{{upstreams 8123}}"
      caddy.tls.protocols: "tls1.3"
      caddy.tls.dns: "cloudflare ${API_TOKEN}"
```

## Resources

https://blog.atkinson.cloud/posts/2021/02/running-caddy-as-a-reverse-proxy-with-cloudflare-dns/

Cloudflare API tokens, find them in your Cloudflare **profile** and look in the left bar for "API Tokens". 

https://dash.cloudflare.com/profile/api-tokens

Caddy cloudflare plugin needs a token Zone - Zone - Read and Zone - DNS - Edit and I set one for map46.com only.

## Other useful commands

Test a CaddyFile.

docker run --rm -v $PWD/Caddyfile:/etc/caddy/Caddyfile caddy:2.4.6 caddy fmt /etc/caddy/Caddyfile

List the current configuration

   CAD=`docker ps | grep caddy-reverse | cut -c 1-12`
   docker exec $CAD curl -s http://localhost:2019/config/ | jq

## Future work

Deal with config issues some more elegant way?

### Swarm

Make it all work under swarm. Currently what's holding me back is Home Assistant, 
which has to be able to access a USB device to talk Zigbee.
Until I work that out, I will be stuck in Compose.

