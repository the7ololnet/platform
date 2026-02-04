#!/bin/bash

set -e

echo "========================================="
echo "Platform Cleanup Script (Cleanup Only)"
echo "========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Kill processes on ports
print_info "Killing processes on ports 8000, 5432, 6379, 80..."
for PORT in 8000 5432 6379 80; do
    if command -v fuser &> /dev/null; then
        sudo fuser -k ${PORT}/tcp 2>/dev/null || true
    else
        PID=$(sudo lsof -ti:${PORT} 2>/dev/null || true)
        if [ ! -z "$PID" ]; then
            sudo kill -9 $PID 2>/dev/null || true
        fi
    fi
done

# Stop system services
print_info "Stopping system PostgreSQL..."
sudo systemctl stop postgresql 2>/dev/null || true
sudo systemctl disable postgresql 2>/dev/null || true
for service in $(systemctl list-units --type=service --all 2>/dev/null | grep -E 'postgresql-[0-9]+' | awk '{print $1}'); do
    sudo systemctl stop $service 2>/dev/null || true
done

print_info "Stopping system Redis..."
sudo systemctl stop redis 2>/dev/null || true
sudo systemctl disable redis 2>/dev/null || true

# Docker cleanup
print_info "Cleaning up Docker..."
docker compose down -v 2>/dev/null || true
docker ps -a | grep -E 'platform-|email-marketing' | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
docker volume ls -qf dangling=true | xargs -r docker volume rm 2>/dev/null || true
docker network prune -f

print_info "Waiting for ports to be released..."
sleep 3

echo ""
print_info "✓ Cleanup complete!"
echo ""
