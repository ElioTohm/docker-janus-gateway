this code was inspired by https://github.com/linagora/docker-janus-gateway
# Janus gateway in a Docker Container

[![Build Status](https://travis-ci.org/linagora/docker-janus-gateway.svg?branch=mach10)](https://travis-ci.org/linagora/docker-janus-gateway)

Run janus gateway well configured for Hublin in a Docker container.

## Usage

Assuming Docker and Docker Compose are installed:

create `.env` file from `.env.example`

```shell
$ cp .env.example .env
```
set the correct instance IP in the .env file

Run the container

```shell
$ docker-compose up -d --build
```

Where `DOCKER_IP` is the public IP address where Docker services can be reached. This will be used by Janus to send back the right IP to Web clients (ICE candidates) so that they can communicate with Janus correctly.

That's it!
