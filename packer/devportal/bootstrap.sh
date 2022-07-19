#!/usr/bin/env bash

set -e

sudo mkdir /etc/ssl/nginx
sudo cp /tmp/nginx-repo.crt /etc/ssl/nginx/
sudo cp /tmp/nginx-repo.key /etc/ssl/nginx/

sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key

sudo apt-get install -y apt-transport-https lsb-release ca-certificates

printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
sudo apt-get update
sudo apt-get install -y nginx-plus
sudo apt-get install -y nginx-plus-module-njs

echo "Install devportal"

sudo apt-get -y install -f /tmp/nginx-devportal.deb /tmp/nginx-devportal-ui.deb

echo "Configure SQLite as backend"
echo 'DP_DB_TYPE="sqlite"' | sudo tee -a /etc/nginx-devportal/devportal.conf
echo 'DP_DB_PATH="/var/lib/nginx-devportal"' | sudo tee -a /etc/nginx-devportal/devportal.conf

sudo systemctl enable nginx-devportal
sudo systemctl start nginx-devportal

# echo "Install postgresql"
# sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# sudo apt-get update
# sudo apt-get -y install postgresql

# cat << EOF | sudo tee /etc/postgresql/<pg_version>/main/pg_hba.conf
# # TYPE  DATABASE        USER            ADDRESS                 METHOD

# local   all             postgres                                peer
# local   all             all                                     md5
# # IPv4 local connections:
# host    all             all             127.0.0.1/32            md5
# # IPv6 local connections:
# host    all             all             ::1/128                 md5
# EOF
# sudo systemctl restart postgresql

# sudo -u postgres createdb devportal
# sudo -u postgres psql -c "CREATE USER nginxdm WITH LOGIN PASSWORD 'nginxdm';"
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE devportal TO nginxdm;"
