#!/bin/bash
set -e

DOCKER_MACHINE_NAME=$1
if [ -z "$DOCKER_MACHINE_NAME" ]; then
  echo Define DOCKER_MACHINE_NAME
  exit 10
fi

# Change it to your Docker Hub user
export DOCKER_USER="peterleonov"
export COMPOSE_FILE="infrastructure.yml"

# Builds locally to save cloud resources and initial context transmission
docker-compose build
# Pushes ready to run images to the Registry using configured Docker Hub account
docker-compose push

(
  # Sets the machine's Docker Daemon as the current one
  eval $(docker-machine env --shell bash $DOCKER_MACHINE_NAME)
  if [ -z "$DOCKER_MACHINE_NAME" ]; then
    echo "Empty DOCKER_MACHINE_NAME" >&2
    echo "Failed to set environment variables for docker machine $DOCKER_MACHINE_NAME" >&2
    exit 20
  fi
  # The `docker network create` command is not indepotent
  # so ignoring errors on second run
  docker network create versions || true
  # Pulling and running
  docker-compose pull
  docker-compose up --no-build -d
)

# Success!
echo "Setup OK on: $DOCKER_MACHINE_NAME"
