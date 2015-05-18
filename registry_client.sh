#!/bin/bash
#root user
#modify /etc/hosts
#rootCA.crt is created by the registry server
#todo: using ssh to control the remote machine and fix the version of images

set -e

if [ "$(id -u)" != "0" ]; then
  echo >&2 "Please run as root"
  exit 1
fi

echo "Please input registry host_name:"
read commonname

read -p "please enter the registry ip > " registryIP
echo "${registryIP} ${commonname}" | sudo tee -a /etc/hosts

sudo mkdir -p /etc/docker/certs.d/${commonname}:5000
sudo mkdir -p /usr/local/share/ca-certificates

sudo cp ./certs/rootCA.crt /etc/docker/certs.d/${commonname}:5000
sudo cp ./certs/rootCA.crt /usr/local/share/ca-certificates

sudo update-ca-certificates
sudo service docker restart
echo "test with docker login ${commonname}:5000"
