#!/bin/bash
set -e

export HOST=$1
if [ -z "$HOST" ]; then
  echo Define HOST
  exit 1
fi

export DOCKER_USER="example"
export COMPOSE_FILE="infrastructure.yml"

docker-compose build
docker-compose push

(
  eval $(docker-machine env --shell bash $HOST)
  docker network create versions || true
  docker-compose pull
  docker-compose up --no-build -d
)


echo
echo "Setup OK on: $HOST"
