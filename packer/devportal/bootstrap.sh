#!/usr/bin/env bash

set -e

echo "Load NGINX repo cert and key"
sudo mkdir /etc/ssl/nginx
sudo cp /tmp/nginx-repo.crt /etc/ssl/nginx/
sudo cp /tmp/nginx-repo.key /etc/ssl/nginx/

echo "Install NGINX Plus and njs"
sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key
sudo apt-get install -y apt-transport-https lsb-release ca-certificates
printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
sudo apt-get update
sudo apt-get install -y nginx-plus
sudo apt-get install -y nginx-plus-module-njs

echo "Add NMS repo"
printf "deb https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
sudo wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx

echo "Install devportal"
sudo apt-get update
sudo apt-get -y install nginx-devportal nginx-devportal-ui

echo "Install postgresql"
PG_FULL_VERSION=12+214ubuntu0.1
PG_MAJOR_VERSION=12
sudo apt-get -y install postgresql=$PG_FULL_VERSION
cat << EOF | sudo tee /etc/postgresql/$PG_MAJOR_VERSION/main/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD

local   all             postgres                                peer
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
EOF
sudo systemctl restart postgresql

echo "Provision postgresql"
sudo -u postgres createdb devportal
sudo -u postgres psql -c "CREATE USER nginxdm WITH LOGIN PASSWORD 'nginxdm';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE devportal TO nginxdm;"

echo "Start Devportal"
sudo systemctl enable nginx-devportal
sudo systemctl start nginx-devportal

echo "Remove NGINX repo cert and key"
sudo rm /etc/ssl/nginx/nginx-repo.crt
sudo rm /etc/ssl/nginx/nginx-repo.key
