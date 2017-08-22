# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [PostgreSQL](http://postgresql.org/).

PostgreSQL is an object-relational database management system (ORDBMS) with an emphasis on extensibility and standards-compliance [[source](https://en.wikipedia.org/wiki/PostgreSQL)].

The image is based on [Debian Jessie](https://www.debian.org/).

This repo is a fork of [sameersbn/docker-postgresql](https://github.com/sameersbn/docker-postgresql).

  1. It's based on Debian Jessie instead of Ubuntu 14.04
  2. It adds build arguments. See [Installation](#installation) for more details.
  3. It makes no modifications to the runtime scripts of the original repo. 
  4. It ehances it with Swarm/Stack mode examples and run/cleanup scripts. See [Quickstart](#quickstart) for more details.

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker vers6` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/voxbox/postgres/) and is the recommended method of installation.

```bash
docker pull voxbox/postgresql:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t voxbox/postgresql github.com/matteolc/docker-jessie-postgresql
```

The following arguments are supported:

  1. PG_VERSION. The Postgresql version to be installed. Defaults to 9.6. 
  2. PG_USER. The Postgresql user. Defaults to postgres.
  3. PG_HOME. Postgresql's home. Defaults to /var/lib/postgresql
  4. PG_RUNDIR. Postgresql's run directory. Defaults to /run/postgresql 
  5. PG_LOGDIR. Postgresql's log directory. Defaults to /var/log/postgresql
  6. PG_CERTDIR. Postgresql's certificates directory. Defaults to /etc/postgres/certs

## Quickstart

Use the sample [docker-compose.yml](docker-compose.yml) files in the examples folder to start the container using [Docker Compose](https://docs.docker.com/compose/)*

All examples use named volumes (not bind mounts). You can change the local driver to a more performant one, such as [overlay](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/#configure-docker-with-the-overlay-or-overlay2-storage-driver).

The examples folder contains scripts that automate the deploy process.

### Master Replica

### Scaling Replicas

### Backup

# Maintenance

## Upgrading

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec` against the running container.



