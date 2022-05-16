#!/usr/bin/env bash

set -e

echo "Install Clickhouse"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4
echo "deb https://repo.clickhouse.tech/deb/stable/ main/" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install clickhouse-server=21.3.10.1 clickhouse-common-static=21.3.10.1

echo "Install NGINX OSS"
sudo apt-get install -y nginx

echo "Install NMS-Platform"
tar -zxvf /tmp/platform-repo.tar.gz
sudo apt-get install -y lsb-release
lsb_release=$(lsb_release -cs)
sudo apt-get -y install -f ./deb/nms-instance-manager_*${lsb_release}_amd64.deb

echo "Restart NGINX OSS"
sudo systemctl restart nginx
sudo systemctl start clickhouse-server
sudo systemctl restart nms

echo "Install NMS-APIM"
sudo apt-get install -y -f /tmp/nms-apim.deb
sudo systemctl start nms
sudo systemctl restart nms-apim
sudo systemctl restart nginx