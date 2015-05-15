#!/bin/sh
#root user
#modify /etc/hosts
echo "input common name:"
read commonname
mkdir /etc/docker/certs.d/${commonname}:5000

cp ./certs/rootCA.crt /etc/docker/certs.d/${commonname}:5000
cp ./certs/rootCA.crt /usr/local/share/ca-certificates

sudo update-ca-certificates
sudo service docker restart
