#!/bin/bash
BUILD_NUMBER=`git rev-parse --short HEAD`
PORT=5000
REG=docker.io
USER=malferov
APP=$REG/$USER/app:$BUILD_NUMBER
sed -i '/CMD/d' Dockerfile
echo CMD [\"$PORT\", \"$BUILD_NUMBER\"] >> Dockerfile
docker build -t $APP --build-arg port=$PORT .
docker login -u $USER $REG
docker push $APP
