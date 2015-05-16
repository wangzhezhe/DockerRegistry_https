#!/bin/sh
# root user
# current dir 
#install docker-compose first
echo  "input the common name used for create rootCA:\c"
read commonname
echo  "input the username:\c"
read username
echo  "input the passwd:\c"
read passwd


# add the user:password
apt-get install apache2-utils
#install expect
apt-get install expect


# add expect code and create user
/usr/bin/expect -c "
spawn htpasswd -c ./nginx/docker-registry.htpasswd $username
expect "*password:"
send $passwd\r
expect "*password:"
send $passwd\r
interact"


if [ ! -d "./certs" ]; then
        mkdir certs
fi

cd certs
#clean the dir
rm -rf *

#create rootCA.key
openssl genrsa -out rootCA.key 2048
#create rootCA.crt
openssl req -x509 -new -nodes -key rootCA.key -days 10000 -out rootCA.crt -subj "/CN=$commonname"
#creste devregistry.key
openssl genrsa -out ${commonname}.key 2048
#create devregistry.csr
openssl req -new -key ${commonname}.key -out ${commonname}.csr -subj "/CN=$commonname"
#create devregistry.crt
openssl x509 -req -in ${commonname}.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out ${commonname}.crt -days 10000


#modify the config file
#modify the nginx.conf after 18 line  insert
#clean the original info before excute 
sed -i "18a \  server_name ${commonname};" ../nginx/nginx.conf

#modify the docker-compose.yml after line 8
#- "./certs/devregistry.key:/etc/nginx/docker-registry.key:ro"
#- "./certs/devregistry.crt:/etc/nginx/docker-registry.crt:ro"
sed -i "8a \    - \"./certs/${commonname}.key:/etc/nginx/docker-registry.key:ro\"" ../docker-compose.yml
sed -i "9a \    - \"./certs/${commonname}.crt:/etc/nginx/docker-registry.crt:ro\"" ../docker-compose.yml

#docker-compose up
cd ..
docker-compose up

echo "please modify the /etc/hosts"
