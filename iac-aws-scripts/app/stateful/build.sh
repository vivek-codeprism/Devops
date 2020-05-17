#!/bin/bash
# build.sh BUILD_NUMBER
BUILD_NUMBER=$1
PORT=5001
REG=docker.io
USER=malferov
APP=db
sed -i '/CMD/d' Dockerfile
echo CMD [\"$PORT\", \"$BUILD_NUMBER\"] >> Dockerfile
docker build -t $APP --build-arg port=$PORT .
TAG=$REG/$USER/$APP:$BUILD_NUMBER
docker tag $APP $TAG
docker login -u $USER $REG
docker push $TAG
