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

echo "Remove NGINX repo cert and key"
sudo rm /etc/ssl/nginx/nginx-repo.crt
sudo rm /etc/ssl/nginx/nginx-repo.key
