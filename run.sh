#!/bin/bash
set -e

# The environment variables file to use as a base for services
export DEPLOYMENT_ENV=$1
if [ -z "$DEPLOYMENT_ENV" ]; then
  echo Define DEPLOYMENT_ENV
  exit 11
fi

export DIRECTOR_VARIANT="local"
export DEPLOY_NS="local"
export COMPOSE_PROJECT_NAME="$DEPLOY_NS"
export DOCKER_USER="local"
export DEPLOY_BUILD="${DEPLOY_NS}@123456"

# To be compatible with deploy.sh
docker network create director_versions || true

exec docker-compose -f docker-compose.yml -f expose-port-8080.yml up --build
