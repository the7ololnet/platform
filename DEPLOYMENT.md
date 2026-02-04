# Deployment Guide - Clean Installation

This guide provides step-by-step instructions for deploying the platform from a clean state, especially when dealing with port conflicts or healthcheck failures.

## Quick Start (Automated)

### Full Reset and Setup

```bash
# Make setup script executable
chmod +x setup.sh

# Run the full setup (cleanup + build + start)
sudo bash setup.sh
```

This script will:
- Kill any processes using ports 8000, 5432, 6379, 80
- Stop and disable system PostgreSQL and Redis services
- Clean up all Docker containers, volumes, and networks
- Rebuild images from scratch
- Start all services
- Verify health checks

### Cleanup Only

```bash
# Make cleanup script executable
chmod +x cleanup-only.sh

# Run cleanup only (no rebuild)
sudo bash cleanup-only.sh
```

---

## Manual Step-by-Step Process

### Step 1: Kill Processes on Conflicting Ports

```bash
# Check what's using the ports
sudo lsof -i :8000
sudo lsof -i :5432
sudo lsof -i :6379
sudo lsof -i :80

# Kill processes using fuser (CentOS/RHEL)
sudo fuser -k 8000/tcp
sudo fuser -k 5432/tcp
sudo fuser -k 6379/tcp
sudo fuser -k 80/tcp

# Or using kill (alternative)
sudo kill -9 $(sudo lsof -ti:8000) 2>/dev/null || true
sudo kill -9 $(sudo lsof -ti:5432) 2>/dev/null || true
sudo kill -9 $(sudo lsof -ti:6379) 2>/dev/null || true
sudo kill -9 $(sudo lsof -ti:80) 2>/dev/null || true
```

### Step 2: Stop System PostgreSQL Service

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Stop and disable it
sudo systemctl stop postgresql
sudo systemctl disable postgresql

# For CentOS specific versions (e.g., postgresql-15)
sudo systemctl stop postgresql-15
sudo systemctl disable postgresql-15

# Verify it's stopped
sudo systemctl status postgresql
```

### Step 3: Stop System Redis Service

```bash
# Check if Redis is running
sudo systemctl status redis

# Stop and disable it
sudo systemctl stop redis
sudo systemctl disable redis

# Verify it's stopped
sudo systemctl status redis
```

### Step 4: Clean Up Docker

```bash
# Stop and remove all containers and volumes
docker compose down -v

# Remove any lingering containers
docker ps -a | grep platform | awk '{print $1}' | xargs docker rm -f

# Remove dangling volumes
docker volume prune -f

# Remove unused networks
docker network prune -f

# (Optional) Clean up everything Docker-related
docker system prune -a --volumes -f
```

### Step 5: Verify Ports Are Free

```bash
# Check all required ports
sudo lsof -i :8000
sudo lsof -i :5432
sudo lsof -i :6379
sudo lsof -i :80

# All should return nothing or "command not found"
```

### Step 6: Verify Environment Configuration

```bash
# Check .env file exists
ls -la .env

# Verify it uses service names, NOT localhost
grep POSTGRES_HOST .env  # Should be "postgres"
grep REDIS_HOST .env     # Should be "redis"

# Your .env should have:
cat .env
```

Expected `.env` content:
```bash
POSTGRES_USER=admin
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=platform
POSTGRES_HOST=postgres          # ← Must be "postgres" not "localhost"
POSTGRES_PORT=5432

REDIS_HOST=redis                # ← Must be "redis" not "localhost"
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

JWT_SECRET_KEY=your_secret_key
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

ENVIRONMENT=production
DEBUG=false

API_V1_PREFIX=/api/v1
PROJECT_NAME=Platform - Email Marketing
```

### Step 7: Build Without Cache

```bash
# Build all images from scratch (no cache)
docker compose build --no-cache
```

This will take 5-10 minutes on first build.

### Step 8: Start Services

```bash
# Start all services in detached mode
docker compose up -d
```

### Step 9: Monitor Startup

```bash
# Watch logs in real-time
docker compose logs -f

# Or watch specific service
docker compose logs -f backend

# Check service status
docker compose ps
```

Expected output:
```
NAME                 STATUS              PORTS
platform-backend     Up (healthy)        0.0.0.0:8000->8000/tcp
platform-frontend    Up (healthy)        0.0.0.0:80->80/tcp
platform-postgres    Up (healthy)        0.0.0.0:5432->5432/tcp
platform-redis       Up (healthy)        0.0.0.0:6379->6379/tcp
```

### Step 10: Verify Health

```bash
# Test backend
curl http://localhost:8000/health

# Expected output:
# {"status":"healthy","service":"email-marketing-platform","environment":"production"}

# Test API
curl http://localhost:8000/api/v1/health

# Test frontend (should return HTML)
curl http://localhost

# Open in browser
firefox http://localhost                      # Frontend
firefox http://localhost:8000/api/v1/docs    # API docs
```

---

## Troubleshooting Common Issues

### Issue: "Port already in use"

```bash
# Find what's using the port
sudo lsof -i :8000

# Kill it
sudo fuser -k 8000/tcp

# Or identify and stop the service
sudo systemctl stop <service-name>
```

### Issue: "Backend unhealthy"

```bash
# Check backend logs
docker compose logs backend

# Common causes:
# 1. Database not ready - wait longer
# 2. Wrong .env values - check POSTGRES_HOST=postgres
# 3. Missing dependencies - rebuild: docker compose build --no-cache backend

# Restart backend
docker compose restart backend

# Check if it can reach postgres
docker compose exec backend ping postgres
```

### Issue: "Cannot connect to database"

```bash
# Verify .env uses service name
grep POSTGRES_HOST .env  # Must be "postgres" not "localhost"

# Check postgres is healthy
docker compose ps postgres

# Check postgres logs
docker compose logs postgres

# Test connection from backend container
docker compose exec backend python -c "from app.core.config import settings; print(settings.database_url)"

# Try connecting manually
docker compose exec postgres psql -U admin -d platform
```

### Issue: "Redis connection failed"

```bash
# Verify .env uses service name
grep REDIS_HOST .env  # Must be "redis" not "localhost"

# Check redis is healthy
docker compose ps redis

# Test redis
docker compose exec redis redis-cli -a your_redis_password ping

# Should return: PONG
```

### Issue: "Healthcheck keeps failing"

```bash
# Check the healthcheck command works inside container
docker compose exec backend python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/health').read())"

# If it fails, check if app is even running
docker compose exec backend ps aux

# Check if port 8000 is listening inside container
docker compose exec backend netstat -tulpn | grep 8000
```

### Issue: "Container keeps restarting"

```bash
# Check logs for errors
docker compose logs backend --tail=100

# Check if dependencies are healthy
docker compose ps

# Remove and recreate
docker compose down
docker compose up -d
```

---

## Complete Rebuild Commands (One-Liner)

### Full cleanup and rebuild:

```bash
sudo bash setup.sh
```

### Manual one-liner:

```bash
sudo fuser -k 8000/tcp 5432/tcp 6379/tcp 80/tcp; \
sudo systemctl stop postgresql redis; \
sudo systemctl disable postgresql redis; \
docker compose down -v; \
docker system prune -f; \
docker compose build --no-cache; \
docker compose up -d; \
docker compose ps
```

---

## Monitoring and Maintenance

```bash
# View all logs
docker compose logs -f

# View resource usage
docker stats

# Restart specific service
docker compose restart backend

# Rebuild and restart specific service
docker compose build backend && docker compose up -d backend

# Stop everything
docker compose stop

# Start everything
docker compose start

# Complete shutdown and cleanup
docker compose down -v
```

---

## Production Checklist

- [ ] .env file configured with strong passwords
- [ ] POSTGRES_HOST=postgres (not localhost)
- [ ] REDIS_HOST=redis (not localhost)
- [ ] System PostgreSQL and Redis disabled
- [ ] Ports 80, 8000, 5432, 6379 are free
- [ ] Firewall rules configured
- [ ] All containers show "healthy" status
- [ ] Health endpoints respond successfully
- [ ] Application accessible from browser

---

## Support

If you still have issues after following this guide:

1. Save logs: `docker compose logs > debug.log`
2. Check port usage: `sudo lsof -i -P -n | grep LISTEN > ports.log`
3. Check service status: `docker compose ps > status.log`
4. Review all three log files for errors
