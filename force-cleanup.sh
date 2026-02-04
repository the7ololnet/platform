#!/bin/bash

set -e

echo "========================================="
echo "AGGRESSIVE Port Cleanup & Docker Reset"
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Stop ALL Docker containers first
print_info "Step 1: Stopping ALL Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null || print_warn "No running containers to stop"

# Step 2: Remove ALL Docker containers
print_info "Step 2: Removing ALL Docker containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || print_warn "No containers to remove"

# Step 3: Kill processes on ports - Method 1 (fuser)
print_info "Step 3: Killing processes on ports (Method 1: fuser)..."
for PORT in 8000 5432 6379 80; do
    print_info "  Checking port ${PORT}..."
    if command -v fuser &> /dev/null; then
        sudo fuser -k ${PORT}/tcp 2>/dev/null || true
    fi
    sleep 0.5
done

# Step 4: Kill processes on ports - Method 2 (lsof + kill)
print_info "Step 4: Killing processes on ports (Method 2: lsof)..."
for PORT in 8000 5432 6379 80; do
    PID=$(sudo lsof -ti:${PORT} 2>/dev/null || true)
    if [ ! -z "$PID" ]; then
        print_warn "  Port ${PORT} still in use by PID ${PID}. Force killing..."
        sudo kill -9 $PID 2>/dev/null || true
        sleep 0.5
    fi
done

# Step 5: Kill processes on ports - Method 3 (netstat)
print_info "Step 5: Killing processes on ports (Method 3: netstat)..."
for PORT in 8000 5432 6379 80; do
    PID=$(sudo netstat -tulpn 2>/dev/null | grep ":${PORT}" | awk '{print $7}' | cut -d'/' -f1 || true)
    if [ ! -z "$PID" ] && [ "$PID" != "-" ]; then
        print_warn "  Port ${PORT} still in use by PID ${PID}. Force killing..."
        sudo kill -9 $PID 2>/dev/null || true
        sleep 0.5
    fi
done

# Step 6: Stop system PostgreSQL
print_info "Step 6: Stopping system PostgreSQL..."
sudo systemctl stop postgresql 2>/dev/null || true
sudo systemctl stop postgresql-* 2>/dev/null || true
sudo systemctl disable postgresql 2>/dev/null || true
sudo pkill -9 postgres 2>/dev/null || true

# Step 7: Stop system Redis
print_info "Step 7: Stopping system Redis..."
sudo systemctl stop redis 2>/dev/null || true
sudo systemctl stop redis-server 2>/dev/null || true
sudo systemctl disable redis 2>/dev/null || true
sudo pkill -9 redis-server 2>/dev/null || true

# Step 8: Docker network cleanup
print_info "Step 8: Cleaning up Docker networks..."
docker network prune -f 2>/dev/null || true
docker network rm platform_platform-network 2>/dev/null || true
docker network rm platform_default 2>/dev/null || true

# Step 9: Docker volume cleanup
print_info "Step 9: Cleaning up Docker volumes..."
docker volume rm platform_postgres_data 2>/dev/null || true
docker volume rm platform_redis_data 2>/dev/null || true
docker volume prune -f 2>/dev/null || true

# Step 10: Remove all docker-compose resources
print_info "Step 10: Removing docker-compose resources..."
docker compose down -v --remove-orphans 2>/dev/null || true

# Step 11: Wait for ports to be released
print_info "Step 11: Waiting for ports to be fully released..."
sleep 5

# Step 12: Final port verification
print_info "Step 12: Final port verification..."
PORTS_BUSY=()
for PORT in 8000 5432 6379 80; do
    if sudo lsof -i:${PORT} &> /dev/null; then
        PORTS_BUSY+=($PORT)
        print_error "  Port ${PORT} is STILL in use:"
        sudo lsof -i:${PORT}
    else
        print_info "  Port ${PORT} is FREE ✓"
    fi
done

echo ""
if [ ${#PORTS_BUSY[@]} -gt 0 ]; then
    print_error "ERROR: The following ports are still in use: ${PORTS_BUSY[*]}"
    echo ""
    print_warn "Manual intervention required. Run these commands:"
    for PORT in "${PORTS_BUSY[@]}"; do
        echo "  sudo lsof -i:${PORT}"
        echo "  sudo kill -9 \$(sudo lsof -ti:${PORT})"
    done
    echo ""
    exit 1
else
    print_info "✓ All ports are free!"
fi

# Step 13: Show what's listening
print_info "Step 13: Current listening ports..."
sudo netstat -tulpn | grep LISTEN | grep -E ':(8000|5432|6379|80) ' || print_info "  No processes on required ports ✓"

echo ""
echo "========================================="
print_info "✓ Aggressive cleanup complete!"
echo "========================================="
echo ""
print_info "Now run: docker compose build --no-cache && docker compose up -d"
echo ""
