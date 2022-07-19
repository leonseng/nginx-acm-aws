#!/usr/bin/env bash

set -e

echo "Install Clickhouse"
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server=21.3.19.1 clickhouse-common-static=21.3.19.1
sudo systemctl start clickhouse-server

echo "Install NGINX OSS"
sudo apt-get install -y nginx

echo "Install NMS-Platform"
sudo apt-get -y install -f /tmp/nms-instance-manager.deb
sudo apt-get -y install -f /tmp/nms-api-connectivity-manager.deb

echo "Enable & start NMS services"
sudo systemctl enable nms
sudo systemctl enable nms-core
sudo systemctl enable nms-dpm
sudo systemctl enable nms-ingestion
sudo systemctl enable nms-acm
sudo systemctl start nms
sudo systemctl start nms-acm
sudo systemctl restart nginx
