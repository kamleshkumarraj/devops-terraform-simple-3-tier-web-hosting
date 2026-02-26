#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "==== Removing old Docker packages if any ===="
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

echo "==== Updating apt ===="
sudo apt update -y

echo "==== Installing prerequisites ===="
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "==== Setting up Docker keyring ===="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "==== Adding Docker repository ===="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==== Updating apt again ===="
sudo apt update -y

echo "==== Installing Docker ===="
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==== Enabling and starting Docker ===="
sudo systemctl enable docker
sudo systemctl start docker

echo "==== Adding current user to docker group ===="
sudo usermod -aG docker $USER

echo "==== Logging in to Docker Hub ===="
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
  echo "ERROR: DOCKER_USERNAME and DOCKER_PASSWORD must be set as environment variables."
  exit 1
fi

echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin

echo "==== Pulling nginx latest image ===="
sudo docker pull nginx:latest

RANDOM_NAME="myapp_$RANDOM"

echo "==== Tagging image with random name: $RANDOM_NAME ===="
sudo docker tag nginx:latest $RANDOM_NAME:latest

echo "==== Creating docker-compose.yml ===="
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  $RANDOM_NAME:
    image: $RANDOM_NAME:latest
    container_name: ${RANDOM_NAME}_container
    ports:
      - "8080:80"
    restart: always
EOF

echo "==== Running docker compose ===="
sudo docker compose up -d

echo "==== Deployment Completed Successfully ===="
echo "Access application at: http://<your-server-ip>:8080"