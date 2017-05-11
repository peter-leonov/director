#!/bin/bash
set -e

COMMENT AS HELL

# deploy clean commits only
if [[ -n $(git status -s) ]]; then
  echo Working directory is not clean.
  echo Do git commit or git reset --hard
  exit 1
fi

export HOST=$1
export ENV=$2
export VARIANT=$3
export PUBLIC_BUILD=$(git rev-parse --short=10 --verify HEAD)

if [ -z "$HOST" ]; then
  echo Define HOST
  exit 1
fi
if [ -z "$ENV" ]; then
  echo Define ENV
  exit 1
fi
if [ -z "$VARIANT" ]; then
  echo Define VARIANT
  exit 1
fi

export DEPLOY_NS="$HOST-$VARIANT"
export COMPOSE_PROJECT_NAME="$DEPLOY_NS"
export DOCKER_USER="example"
echo "Deploying to: $DEPLOY_NS"

docker-compose build
docker-compose push

(
  # fail if docker-machine env fails
  docker-machine env --shell bash $HOST > .docker-machine-env-$HOST
  eval $(cat .docker-machine-env-$HOST)

  docker volume create --name=event_logs
  docker-compose pull

  docker-compose down -v
  docker-compose up --no-build -d
  docker system prune -f
)

git tag ${DEPLOY_NS}__$(date +"%Y%m%d-%H%M%S")
git push --tags upstream

echo
echo "Deployed OK to: $DEPLOY_NS"
