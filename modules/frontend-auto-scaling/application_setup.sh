#!/bin/bash

set -euo pipefail

APP_DIR="/opt/frontend"
PROJECT_NAME="frontend"

echo "==== Updating system ===="
sudo apt update -y

echo "==== Installing prerequisites ===="
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    zip \
    software-properties-common

# Install AWS CLI v2

if ! command -v aws &> /dev/null
then
    echo "==== Installing AWS CLI v2 ===="
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -oq awscliv2.zip
    sudo ./aws/install --update
    rm -rf aws awscliv2.zip
else
    echo "==== AWS CLI already installed ===="
fi

aws --version

# Install Docker

echo "==== Removing old Docker packages if any ===="
sudo apt remove -y docker docker-engine docker.io containerd runc || true

sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl restart docker

# Create App Directory

echo "==== Preparing application directory ===="
sudo mkdir -p ${APP_DIR}
sudo chown -R $USER:$USER ${APP_DIR}
cd ${APP_DIR}

# ECR Login

echo "==== Logging in to AWS ECR ===="

aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 768289995096.dkr.ecr.ap-south-1.amazonaws.com

# Pull Image

echo "==== Pulling latest frontend image ===="
docker pull 768289995096.dkr.ecr.ap-south-1.amazonaws.com/ecommerce/frontend-main:latest

# Create docker-compose.yml

echo "==== Creating docker-compose.yml ===="

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  frontend:
    image: 768289995096.dkr.ecr.ap-south-1.amazonaws.com/ecommerce/frontend-main:latest
    container_name: frontend_container
    ports:
      - "80:80"
    restart: always
EOF

# Run Docker Compose

echo "==== Starting Application ===="
docker compose -p ${PROJECT_NAME} down || true
docker compose -p ${PROJECT_NAME} up -d

echo "====================================================="
echo "✅ Deployment Completed Successfully"
echo "Access application at: http://ecommerce.viarfood.in"
echo "====================================================="