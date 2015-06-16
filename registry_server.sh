#!/bin/bash
# root user
# current dir 
# install docker-compose first
echo  "input the common name used for create rootCA:\c"
read commonname
echo  "input the username:\c"
read username
echo  "input the passwd:\c"
read passwd


# add the user:password
sudo apt-get install apache2-utils
#install expect
sudo apt-get install expect

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

#todo: create a dir including decessary file for client using


#if get problems of : curl: (60) SSL certificate problem: self signed certificate...
#refer to http://stackoverflow.com/questions/94445/using-openssl-what-does-unable-to-write-random-state-mean
# do not set the commonname to the ip or localhost when create the ca.crt It's better to use some domain just like abc.com

#注意 server 端生成 server.crt 证书的时候 貌似不能直接使用ip 需要在/etc/hosts 中配置对应的别名 比如 servername xx.xx.xx.xx
#要不然 可能会遇到 Get https://10.10.105.204:2379/v2/keys/foo: x509: cannot validate certificate for 10.10.105.204 because it doesn't contain any IP SANs
#配置etcd的https的时候就遇到了类似的问题
