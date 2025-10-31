#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================
  🚀 Démarrage de DefectDojo
==================================================${NC}"

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

if ! command -v docker &> /dev/null; then
    log_error "Docker non installé!"
    exit 1
fi
log_success "Docker: $(docker --version)"

if [ ! -f .env ]; then
    log_error "Fichier .env manquant!"
    exit 1
fi

export $(cat .env | grep -v '^#' | xargs)

log_info "Téléchargement des images..."
docker-compose pull

log_info "Démarrage..."
docker-compose up -d

log_info "Attente (2-3 min)..."
sleep 30

MAX_ATTEMPTS=20
for i in $(seq 1 $MAX_ATTEMPTS); do
    if curl -s http://localhost:${DD_PORT:-8080}/login 2>/dev/null | grep -q "DefectDojo"; then
        log_success "DefectDojo prêt!"
        echo ""
        echo -e "${GREEN}✅ Installation réussie!${NC}"
        echo "🌐 URL: http://localhost:${DD_PORT:-8080}"
        echo "👤 User: admin"
        echo "🔑 Pass: ${DD_ADMIN_PASSWORD}"
        exit 0
    fi
    echo "Tentative $i/$MAX_ATTEMPTS..."
    sleep 10
done

log_error "Timeout - Vérifiez: docker-compose logs"
exit 1
