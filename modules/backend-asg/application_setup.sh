#!/bin/bash

set -euo pipefail

APP_DIR="/opt/backend"
PROJECT_NAME="ecommerce-backend"


echo "==== Updating system ===="
sudo apt update -y

IMAGE=$(aws ssm get-parameter \
--name "ecommerce-backend-image" \
--query "Parameter.Value" \
--output text)

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

echo "==== Pulling latest backend image ===="
docker pull 768289995096.dkr.ecr.ap-south-1.amazonaws.com/$IMAGE

# Create docker-compose.yml

echo "==== Creating docker-compose.yml ===="

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  backend:
    image: 768289995096.dkr.ecr.ap-south-1.amazonaws.com/$IMAGE
    container_name: backend_container
    ports:
      - "4000:2000"
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