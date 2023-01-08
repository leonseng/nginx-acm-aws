#!/usr/bin/env bash

set -e

echo "Load NGINX repo cert and key"
sudo mkdir /etc/ssl/nginx
sudo cp /tmp/nginx-repo.crt /etc/ssl/nginx/
sudo cp /tmp/nginx-repo.key /etc/ssl/nginx/

echo "Update apt repos"
sudo apt-get update

echo "Add Clickhouse repo"
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list

echo "Add NMS repo"
printf "deb https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
sudo wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key

echo "Update apt repos"
sudo apt-get update

echo "Install Clickhouse"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client

echo "Enable Clickhouse to start at boot"
sudo systemctl enable clickhouse-server

echo "Install NGINX OSS"
sudo apt-get install -y nginx

echo "Install ACM"
sudo apt-get install -y nms-api-connectivity-manager

echo "Enable NMS services to start at boot"
sudo systemctl enable nms
ps aufx | grep nms
sudo systemctl restart nginx

echo "Patch NMS conf to enable API credentials in Devportal"
sudo sh -c 'cat > /etc/nms/nginx/locations/nms-acm-devportal-creds.conf <<EOF
location = /api/acm/v1/devportal/credentials {
        auth_basic off;
        error_page 401 /401_certs.json;
        proxy_pass http://acm-api-service/api/acm/v1/devportal/credentials;
}
EOF'
sudo nginx -s reload

echo "Remove NGINX repo cert and key"
sudo rm /etc/ssl/nginx/nginx-repo.crt
sudo rm /etc/ssl/nginx/nginx-repo.key
