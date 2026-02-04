#!/bin/bash

set -e

echo "========================================="
echo "Platform Reset & Setup Script"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Kill processes on conflicting ports
print_info "Step 1: Checking for processes on ports 8000, 5432, 6379, 80..."

PORTS=(8000 5432 6379 80)
for PORT in "${PORTS[@]}"; do
    if command -v fuser &> /dev/null; then
        # Using fuser (preferred)
        if sudo fuser ${PORT}/tcp &> /dev/null; then
            print_warn "Port ${PORT} is in use. Killing process..."
            sudo fuser -k ${PORT}/tcp || true
            sleep 1
        else
            print_info "Port ${PORT} is free"
        fi
    else
        # Fallback to lsof + kill
        PID=$(sudo lsof -ti:${PORT} || true)
        if [ ! -z "$PID" ]; then
            print_warn "Port ${PORT} is in use by PID ${PID}. Killing..."
            sudo kill -9 $PID || true
            sleep 1
        else
            print_info "Port ${PORT} is free"
        fi
    fi
done

# Step 2: Stop and disable system PostgreSQL
print_info "Step 2: Stopping system PostgreSQL service..."
if systemctl is-active --quiet postgresql; then
    print_warn "PostgreSQL service is running. Stopping..."
    sudo systemctl stop postgresql || true
    sudo systemctl disable postgresql || print_warn "Could not disable PostgreSQL"
else
    print_info "PostgreSQL service is not running"
fi

# Also check for postgresql-* services (CentOS variants)
for service in $(systemctl list-units --type=service --all | grep -E 'postgresql-[0-9]+' | awk '{print $1}'); do
    print_warn "Found $service, stopping..."
    sudo systemctl stop $service || true
    sudo systemctl disable $service || print_warn "Could not disable $service"
done

# Step 3: Stop and disable system Redis
print_info "Step 3: Stopping system Redis service..."
if systemctl is-active --quiet redis; then
    print_warn "Redis service is running. Stopping..."
    sudo systemctl stop redis || true
    sudo systemctl disable redis || print_warn "Could not disable Redis"
else
    print_info "Redis service is not running"
fi

# Step 4: Clean up Docker containers and volumes
print_info "Step 4: Cleaning up Docker containers, volumes, and networks..."

if command -v docker &> /dev/null; then
    # Stop and remove containers
    docker compose down -v 2>/dev/null || print_warn "No existing containers to remove"
    
    # Remove any orphaned containers related to this project
    docker ps -a | grep -E 'platform-|email-marketing' | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
    
    # Remove dangling volumes
    docker volume ls -qf dangling=true | xargs -r docker volume rm 2>/dev/null || true
    
    # Prune networks
    docker network prune -f
    
    print_info "Docker cleanup completed"
else
    print_error "Docker is not installed!"
    exit 1
fi

# Step 5: Verify .env file exists
print_info "Step 5: Checking environment configuration..."

if [ ! -f .env ]; then
    print_warn ".env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_warn "Please edit .env file with your configuration before continuing!"
        print_warn "Run: nano .env"
        exit 1
    else
        print_error ".env.example not found!"
        exit 1
    fi
else
    print_info ".env file exists"
fi

# Step 6: Verify environment variables use service names
print_info "Step 6: Validating environment configuration..."

if grep -q "localhost" .env 2>/dev/null; then
    print_warn "Found 'localhost' in .env file. Docker services should use service names!"
    print_warn "Make sure POSTGRES_HOST=postgres and REDIS_HOST=redis"
fi

# Step 7: Wait for ports to be fully released
print_info "Step 7: Waiting for ports to be fully released..."
sleep 3

# Step 8: Verify ports are free
print_info "Step 8: Final port verification..."
PORTS_BUSY=()
for PORT in "${PORTS[@]}"; do
    if sudo lsof -i:${PORT} &> /dev/null; then
        PORTS_BUSY+=($PORT)
    fi
done

if [ ${#PORTS_BUSY[@]} -gt 0 ]; then
    print_error "The following ports are still in use: ${PORTS_BUSY[*]}"
    print_error "Please manually check: sudo lsof -i:<port>"
    exit 1
else
    print_info "All ports are free!"
fi

# Step 9: Build Docker images
print_info "Step 9: Building Docker images (this may take several minutes)..."
docker compose build --no-cache

# Step 10: Start containers
print_info "Step 10: Starting containers..."
docker compose up -d

# Step 11: Wait for services to be healthy
print_info "Step 11: Waiting for services to become healthy..."
sleep 10

# Step 12: Check service status
print_info "Step 12: Checking service status..."
docker compose ps

# Step 13: Test backend health endpoint
print_info "Step 13: Testing backend health endpoint..."
sleep 5

for i in {1..10}; do
    if curl -f http://localhost:8000/health &> /dev/null; then
        print_info "✓ Backend is healthy!"
        curl -s http://localhost:8000/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8000/health
        break
    else
        if [ $i -eq 10 ]; then
            print_error "Backend health check failed after 10 attempts"
            print_info "Checking backend logs..."
            docker compose logs backend --tail=50
        else
            print_warn "Waiting for backend to be ready (attempt $i/10)..."
            sleep 5
        fi
    fi
done

echo ""
echo "========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Access your application:"
echo "  Frontend:  http://localhost"
echo "  Backend:   http://localhost:8000"
echo "  API Docs:  http://localhost:8000/api/v1/docs"
echo ""
echo "Useful commands:"
echo "  View logs:        docker compose logs -f"
echo "  Stop services:    docker compose stop"
echo "  Restart services: docker compose restart"
echo "  Full cleanup:     bash setup.sh"
echo ""
