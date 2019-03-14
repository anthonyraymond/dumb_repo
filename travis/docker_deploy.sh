#!/usr/bin/env bash

# Inspired from : https://github.com/zeerorg/cron-connector/blob/master/travis/deploy.sh

REPO_NAME="anthonyraymond/dumb_repository"

# Login into docker
docker login --username "$DOCKER_USERNAME" --password "$DOCKERHUB_PASSWORD"


--frontend-opt filename=./Dockerfile --exporter image --exporter-opt name=docker.io/anthonyraymond/dumb_repository:2.1.13 --exporter-opt push=true --progress=plain

architectures="arm arm64 amd64"
images=""
platforms=""

for arch in $architectures
do
# Build for all architectures and push manifest
  platforms="linux/$arch,$platforms"
done

platforms=${platforms::-1}


# Push multi-arch image
buildctl build --frontend dockerfile.v0 \
      --local dockerfile=. \
      --local context=. \
      --exporter image \
      --exporter-opt name=docker.io/$REPO_NAME:$TRAVIS_TAG \
      --exporter-opt push=true \
      --frontend-opt platform=$platforms \
      --frontend-opt filename=./Dockerfile

# Push image for every arch with arch prefix in tag
for arch in $architectures
do
# Build for all architectures and push manifest
  buildctl build --frontend dockerfile.v0 \
      --local dockerfile=. \
      --local context=. \
      --exporter image \
      --exporter-opt name=docker.io/$REPO_NAME:$TRAVIS_TAG-$arch \
      --exporter-opt push=true \
      --frontend-opt platform=linux/$arch \
      --frontend-opt filename=./Dockerfile &
done

wait

docker pull $REPO_NAME:$TRAVIS_TAG
docker tag $REPO_NAME:$TRAVIS_TAG $REPO_NAME:latest
docker push $REPO_NAME:latest