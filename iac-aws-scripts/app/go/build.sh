#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
make deps build
chmod +x app
sudo docker build -t app .
sudo docker tag app malferov/app:$1
sudo docker login
sudo docker push malferov/app
