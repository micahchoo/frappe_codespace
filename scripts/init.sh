#!/bin/bash

set -e

# Ensure we start fresh
rm -rf /workspace/frappe-bench

# Set up Node.js and Yarn
source /home/frappe/.nvm/nvm.sh
nvm install 18
nvm alias default 18
nvm use 18
npm install -g yarn

echo "nvm use 18" >> ~/.bashrc

# Initialize the bench in the correct directory
cd /workspace

bench init \
--ignore-exist \
--skip-redis-config-generation \
frappe-bench

# Change to the newly created bench directory
cd /workspace/frappe-bench

# Configure bench to use containerized services
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis-cache:6379
bench set-redis-queue-host redis://redis-queue:6379
bench set-redis-socketio-host redis://redis-socketio:6379

# Remove redis from Procfile as it's handled by the container
sed -i '/redis/d' ./Procfile

# Create a new site with the correct database credentials
bench new-site dev.localhost \
--mariadb-root-username root \
--mariadb-root-password 123 \
--admin-password admin \
--mariadb-user-host-login-scope='%'

# Set developer mode and clear cache
bench --site dev.localhost set-config developer_mode 1
bench --site dev.localhost clear-cache
bench use dev.localhost

echo "Frappe bench initialized successfully!"
