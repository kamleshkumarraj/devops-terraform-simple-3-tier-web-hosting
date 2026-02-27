#!/bin/bash

set -euo pipefail

APP_DIR="/opt/mongo-app"
PROJECT_NAME="mongo"

echo "==== Updating system ===="
apt update -y

echo "==== Installing prerequisites ===="
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    zip \
    software-properties-common

############################################################
# Install Docker
############################################################

echo "==== Removing old Docker packages if any ===="
apt remove -y docker docker-engine docker.io containerd runc || true

install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
    chmod a+r /etc/apt/keyrings/docker.asc
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl restart docker

############################################################
# Create App Directory
############################################################

echo "==== Preparing application directory ===="
mkdir -p ${APP_DIR}
cd ${APP_DIR}

############################################################
# Pull Public Mongo Image
############################################################

echo "==== Pulling MongoDB public image ===="
docker pull mongo:7

############################################################
# Create docker-compose.yml
############################################################

echo "==== Creating docker-compose.yml ===="

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  mongo:
    image: mongo:7
    container_name: mongo_container
    ports:
      - "27017:27017"
    restart: always
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
EOF

############################################################
# Run Docker Compose
############################################################

echo "==== Starting MongoDB ===="
docker compose -p ${PROJECT_NAME} down || true
docker compose -p ${PROJECT_NAME} up -d

echo "====================================================="
echo "✅ MongoDB Deployment Completed Successfully"
echo "Mongo running on port 27017"
echo "====================================================="