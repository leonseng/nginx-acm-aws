#!/usr/bin/env bash

set -e

echo "Load NGINX repo cert and key"
sudo mkdir /etc/ssl/nginx
sudo cp /tmp/nginx-repo.crt /etc/ssl/nginx/
sudo cp /tmp/nginx-repo.key /etc/ssl/nginx/

echo "Install Clickhouse"
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server=21.3.19.1 clickhouse-common-static=21.3.19.1
sudo systemctl start clickhouse-server

echo "Install NGINX OSS"
sudo apt-get install -y nginx

echo "Add NMS repo"
printf "deb https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
sudo wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key

echo "Install NIM and ACM"
sudo apt-get update
sudo apt-get install -y nms-instance-manager nms-api-connectivity-manager

echo "Enable & start NMS services"
sudo systemctl enable nms
sudo systemctl enable nms-core
sudo systemctl enable nms-dpm
sudo systemctl enable nms-ingestion
sudo systemctl enable nms-acm
sudo systemctl start nms
sudo systemctl start nms-acm
sudo systemctl restart nginx
