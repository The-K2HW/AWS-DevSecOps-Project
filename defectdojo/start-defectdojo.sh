#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================
  🚀 Starting DefectDojo
==================================================${NC}"

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed!"
    exit 1
fi
log_success "Docker: $(docker --version)"

if [ ! -f .env ]; then
    log_error ".env file is missing!"
    exit 1
fi

export $(cat .env | grep -v '^#' | xargs)

CHECK_URL="http://localhost:${DD_PORT:-8080}"
DISPLAY_URL=${DD_HOST:-$CHECK_URL}


log_info "Pulling Docker images..."
docker-compose pull

log_info "Starting containers..."
docker-compose up -d

log_info "Waiting for services to be ready (this may take 2-3 min)..."
sleep 30

MAX_ATTEMPTS=20
for i in $(seq 1 $MAX_ATTEMPTS); do
    if curl -s ${CHECK_URL}/login 2>/dev/null | grep -q "DefectDOJO"; then
        log_success "DefectDojo is ready!"
        echo ""
        echo -e "${GREEN}✅ Installation successful!${NC}"
        echo "🌐 URL: ${DISPLAY_URL}"
        echo "👤 User: admin"
        echo "🔑 Pass: ${DD_ADMIN_PASSWORD}"
        exit 0
    fi
    echo "Attempt $i/$MAX_ATTEMPTS..."
    sleep 10
done

log_error "Timeout - Check logs with: docker-compose logs"
exit 1
