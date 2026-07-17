#!/bin/bash
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "=== Frontend Deployment Started at $(date) ==="

echo "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io curl unzip

echo "Starting Docker service..."
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Installing AWS CLI..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
    echo "Logging into Docker Hub..."
    echo "${dockerhub_password}" | docker login -u "${dockerhub_username}" --password-stdin
else
    echo "Using public Docker image (no credentials provided)"
fi

echo "Pulling frontend image: ${docker_image}"
docker pull ${docker_image}

# NOTE: this image is a static React build served by nginx. The backend URL
# (REACT_APP_API_URL) is compiled into the JS bundle at BUILD time in CI —
# it cannot be injected here via -e, since nginx never reads that env var.
# If the backend URL changes, the image must be rebuilt, not just redeployed.

echo "Starting frontend container on port 3000 (host) -> 80 (container, nginx)..."
docker run -d \
  --name items-frontend \
  --restart unless-stopped \
  -p 3000:80 \
  ${docker_image}

sleep 5
if docker ps | grep -q items-frontend; then
    echo "✓ Frontend container is running"
    docker logs items-frontend
else
    echo "✗ Frontend container failed to start"
    docker logs items-frontend
    exit 1
fi

echo "=== Frontend Deployment Completed at $(date) ==="
