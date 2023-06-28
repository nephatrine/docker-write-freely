[Git](https://code.nephatrine.net/NephNET/docker-write-freely/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/write-freely/) |
[unRAID](https://code.nephatrine.net/NephNET/unraid-containers)

# WriteFreely Blog/Notes Server

This docker image contains a WriteFreely server to self-host your own blog(s).

The `latest` tag points to version `0.13.2` and this is the only image actively
being updated. There are tags for older versions, but these may no longer be
using the latest Alpine version and packages.

To secure this service, we suggest a separate reverse proxy server, such as an
[NGINX](https://nginx.com/) container. Alternatively, WriteFreely does include
built-in options for using your own SSL certificates or using LetsEncrypt.

## Docker-Compose

This is an example docker-compose file:

```yaml
services:
  write-freely:
    image: nephatrine/write-freely:latest
    container_name: write-freely
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    ports:
      - "70:70/tcp"
      - "8080:8080/tcp"
    volumes:
      - /mnt/containers/write-freely:/mnt/config
```

## Admin Creation

You will likely want to create an admin account after installation. You can do
that by using the container's terminal to run the following command:

```bash
writefreely -c /mnt/config/etc/writefreely/config.ini --create-admin [username]:[password]
```

This will create your initial admin user account.

## Server Configuration

There are some important configuration files you need to be aware of and
potentially customize.

- `/mnt/config/etc/writefreely/config.ini`
- `/mnt/config/www/writefreely/pages/*`
- `/mnt/config/www/writefreely/static/*`
- `/mnt/config/www/writefreely/templates/*`

Modifications to these files will require a service restart to pull in the
changes made.
