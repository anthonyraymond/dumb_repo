#!/usr/bin/env bash

# Inspired from : https://github.com/zeerorg/cron-connector/blob/master/travis/deploy.sh


REPO_NAME="anthonyraymond/dumb_repository"

# Login into docker
docker login --username anthonyraymond --password "$DOCKERHUB_PASSWORD"


architectures="amd64 arm arm64"
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
      --output type=image,name=docker.io/$REPO_NAME:$TRAVIS_TAG,push=true \
      --opt platform=$platforms \
      --opt filename=./Dockerfile


# Push image for every arch with arch prefix in tag
for arch in $architectures
do
# Build for all architectures and push manifest
  buildctl build --frontend dockerfile.v0 \
      --local dockerfile=. \
      --local context=. \
      --output type=image,name=docker.io/$REPO_NAME:$TRAVIS_TAG-$arch,push=true \
      --opt platform=linux/$arch \
      --opt filename=./Dockerfile &
done

wait

docker pull $REPO_NAME:$TRAVIS_TAG
docker tag $REPO_NAME:$TRAVIS_TAG $REPO_NAME:latest
docker push $REPO_NAME:latest