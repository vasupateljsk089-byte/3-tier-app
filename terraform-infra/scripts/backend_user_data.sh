#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting backend setup..."

# Update system
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Docker and dependencies
log "Installing Docker and utilities..."
apt-get install -y docker.io jq unzip curl
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
log "✅ Docker installed and started successfully"

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

REGION="${region}"
log "Region: $REGION"

# Docker Hub login (if credentials provided)
if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
    log "Logging into Docker Hub..."
    if ! echo "${dockerhub_password}" | docker login -u "${dockerhub_username}" --password-stdin; then
        log "❌ ERROR: Failed to login to Docker Hub"
        exit 1
    fi
    log "✅ Successfully logged into Docker Hub"
else
    log "No Docker Hub credentials provided, assuming public image"
fi

# Get database credentials from Secrets Manager
log "Retrieving database credentials from Secrets Manager..."
SECRET=$(aws secretsmanager get-secret-value --secret-id ${db_secret_arn} --region $REGION --query SecretString --output text)

if [ -z "$SECRET" ]; then
    log "❌ ERROR: Failed to retrieve database credentials"
    exit 1
fi

# Map Secrets Manager fields (username/password/host/port/dbname) to the
# env var names the items backend actually reads (db.js): DB_USER, DB_PASSWORD,
# DB_HOST, DB_PORT, DB_NAME, DB_SSL
DB_USER=$(echo $SECRET | jq -r '.username')
DB_PASSWORD=$(echo $SECRET | jq -r '.password')
DB_HOST=$(echo $SECRET | jq -r '.host')
DB_PORT=$(echo $SECRET | jq -r '.port')
DB_NAME=$(echo $SECRET | jq -r '.dbname')

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_PORT" ]; then
    log "❌ ERROR: Failed to retrieve all required database secrets from Secrets Manager"
    exit 1
fi

log "✅ Database configuration retrieved successfully"
log "DB Host: $DB_HOST"
log "DB Port: $DB_PORT"
log "DB Name: $DB_NAME"

# Configure Docker log rotation BEFORE starting any container, since restarting
# the daemon after a container is running would kill it (unless live-restore is set)
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
systemctl restart docker

# Pull and run backend container
log "Pulling backend image from Docker Hub..."
docker pull ${docker_image}

log "Starting backend container..."
docker run -d \
  --name items-backend \
  --restart unless-stopped \
  -p 4000:4000 \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="$DB_PORT" \
  -e DB_NAME="$DB_NAME" \
  -e DB_SSL=true \
  -e PORT=4000 \
  ${docker_image}

sleep 10

if docker ps | grep -q items-backend; then
    log "✅ Backend container is running"
else
    log "❌ ERROR: Backend container failed to start"
    docker logs items-backend
    exit 1
fi

# Boot-time readiness wait (the ALB target group is the real health gate;
# this just avoids marking the instance "ready" before the app can respond)
log "Waiting for backend to respond..."
for i in {1..15}; do
    if curl -s http://localhost:4000/api/health > /dev/null 2>&1; then
        log "✅ Backend is responding to requests"
        break
    fi
    sleep 2
done

log "✅ Backend setup completed successfully!"
log "Container logs: docker logs -f items-backend"
