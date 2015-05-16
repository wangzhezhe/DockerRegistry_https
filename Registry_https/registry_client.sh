#!/bin/sh
#root user
#modify /etc/hosts
#rootCA.crt is created by the registry server
#todo: using ssh to control the remote machine and fix the version of images
echo "input common name:"
read commonname
mkdir /etc/docker/certs.d/${commonname}:5000

cp ./certs/rootCA.crt /etc/docker/certs.d/${commonname}:5000
cp ./certs/rootCA.crt /usr/local/share/ca-certificates

sudo update-ca-certificates
sudo service docker restart
echo "test with docker login ${commonname}:5000"
