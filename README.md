# docker-caddy

Caddy webserver running in Docker, set up for use as a reverse proxy and static content server.

## Command to run an HTTP server.

docker run -p 80:80 -v caddy_data:/data caddy

docker-compose up -d

## How to reload

docker exec caddy_caddy_1 caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile




Matomo web site analytics.

## Solve these problems to determine if it is suitable.

* Support more than one FQDN (virtual hosts)
* Support static content on different paths
* Reverse proxy many services, on different virtual hosts
* Can it run in SWARM mode? This would allow me to run the proxy on one machine and have services on others.
For example, I could put webforms.co.clatsop.or.us on cc-giscache and put the actual Flask docker on cc-testmaps.
This is not essential but would be great to separate development from production.

### Real life example from cc-giscache

* https://giscache.co.clatsop.or.us/   reverse for mapproxy service
* https://giscache.co.clatsop.or.us/PDF  static content for a folder out on the network fileserver
* https://giscache.co.clatsop.or.us/photoshow/  reverse for photoshow service
* https://giscache.co.clatsop.or.us/photo/  reverse for property_api Flask service
* https://capacity.co.clatsop.or.us/   reverse for an nginx instance service static content
* https://webforms.co.clatsop.or.us/   reverse for a flask app
