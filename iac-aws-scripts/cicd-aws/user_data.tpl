#!/bin/bash
${yum} docker
sudo systemctl start docker
sudo docker run -d -p 5000:5000 -e MYSQL_HOST=${mysql_host} --log-driver gelf --log-opt gelf-address=udp://${elk}:12201 ${docker_id}/app:${version}
