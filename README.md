<!--
SPDX-FileCopyrightText: 2023-2025 Daniel Wolf <nephatrine@gmail.com>
SPDX-License-Identifier: ISC
-->

# WriteFreely Blog/Notes Server

[![NephCode](https://img.shields.io/static/v1?label=Git&message=NephCode&color=teal)](https://code.nephatrine.net/NephNET/docker-write-freely)
[![GitHub](https://img.shields.io/static/v1?label=Git&message=GitHub&color=teal)](https://github.com/nephatrine/docker-write-freely)
[![Registry](https://img.shields.io/static/v1?label=OCI&message=NephCode&color=blue)](https://code.nephatrine.net/NephNET/-/packages/container/write-freely/latest)
[![DockerHub](https://img.shields.io/static/v1?label=OCI&message=DockerHub&color=blue)](https://hub.docker.com/repository/docker/nephatrine/write-freely/general)
[![unRAID](https://img.shields.io/static/v1?label=unRAID&message=template&color=orange)](https://code.nephatrine.net/NephNET/unraid-containers)

This is an Alpine-based container hosting the WriteFreely blogging web service.

To secure this service, we suggest a separate reverse proxy server, such as
[nephatrine/nginx-ssl](https://hub.docker.com/repository/docker/nephatrine/nginx-ssl/general).

To support blog comments, we recommend integrating a comment service such as
[nephatrine/remark42-ce](https://hub.docker.com/repository/docker/nephatrine/remark42-ce/general).

## Supported Tags

- `write-freely:0.16.0`: WriteFreely 0.16.0

## Software

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet S6](https://skarnet.org/software/s6/)
- [s6-overlay](https://github.com/just-containers/s6-overlay)
- [WriteFreely](https://writefreely.org/)
- [SQLite](https://sqlite.org/)

## Configuration

You will likely want to create an admin account after installation. You can do
that by using the container's terminal to run the following command:

```bash
writefreely -c /mnt/config/etc/writefreely.ini --create-admin [username]:[password]
```

There are some important configuration files you need to be aware of and
potentially customize.

- `/mnt/config/etc/writefreely.ini`

Modifications to these files will require a service restart to pull in the
changes made.

You can place any additional web files to be served here.

- `/mnt/config/www/writefreely/*`

### Container Variables

- `TZ`: Time Zone (i.e. `America/New_York`)
- `PUID`: Mounted File Owner User ID
- `PGID`: Mounted File Owner Group ID

## Testing

### docker-compose

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

### docker run

```bash
docker run --rm -ti code.nephatrine.net/nephnet/write-freely:latest /bin/bash
```
