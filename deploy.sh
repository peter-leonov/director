#!/bin/bash
set -e

# The docker machine name we deploy to
DOCKER_MACHINE_NAME=$1
if [ -z "$DOCKER_MACHINE_NAME" ]; then
  echo Define DOCKER_MACHINE_NAME
  exit 10
fi

# The environment variables file to use as a base for services
export DEPLOYMENT_ENV=$2
if [ -z "$DEPLOYMENT_ENV" ]; then
  echo Define DEPLOYMENT_ENV
  exit 11
fi

# The deployment variant name which will be the host name, should start with "v"
export DIRECTOR_VARIANT=$3
if [ -z "$DIRECTOR_VARIANT" ]; then
  echo Define DIRECTOR_VARIANT
  exit 12
fi

# The namespace to split different image versions in Registry
export DEPLOY_NS="$DOCKER_MACHINE_NAME-$DIRECTOR_VARIANT"
# ...and in Docker Daemon
export COMPOSE_PROJECT_NAME="$DEPLOY_NS"
# Change it to your Docker Hub user
export DOCKER_USER="example"
# For use in the application to show the exact commit and configuration
export DEPLOY_BUILD="${DEPLOY_NS}@$(git rev-parse --short=10 --verify HEAD)"

echo "Deploying to: $DEPLOY_NS"
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

  # Pulls first all the required images
  docker-compose pull
  # Explicitly runs containers without rebuilding in daemon mode
  docker-compose up --no-build -d
)

# Notifies other team members of what has been deployed
git tag ${DEPLOY_NS}__$(date +"%Y%m%d-%H%M%S")
git push --tags upstream

# Success!
echo "Deployed OK to: $DEPLOY_NS"
