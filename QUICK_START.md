# 🚀 QUICK START - Clean Installation

## Option 1: Automated Setup (Recommended)

Run this **single command** for complete automated setup:

```bash
cd /home/$USER/platform
sudo bash setup.sh
```

**What it does:**
- ✓ Kills processes on ports 8000, 5432, 6379, 80
- ✓ Stops system PostgreSQL and Redis services
- ✓ Cleans up all Docker containers and volumes
- ✓ Rebuilds images from scratch
- ✓ Starts all services
- ✓ Verifies health checks
- ✓ Shows you the final status

**Time:** ~5-10 minutes

---

## Option 2: Manual Step-by-Step

### Step 1: Clone Repository

```bash
cd /home/$USER
git clone https://github.com/the7ololnet/platform.git
cd platform
git checkout cursor/agents-md-file-33f5
```

### Step 2: Configure Environment

```bash
# Copy example .env
cp .env.example .env

# Edit .env with your passwords
nano .env
```

**IMPORTANT:** Make sure these values are set correctly in `.env`:
```bash
POSTGRES_HOST=postgres    # NOT localhost
REDIS_HOST=redis          # NOT localhost
```

### Step 3: Run Setup Script

```bash
sudo bash setup.sh
```

---

## Option 3: If You Already Have the Repo

```bash
cd /home/$USER/platform
git pull origin cursor/agents-md-file-33f5
sudo bash setup.sh
```

---

## Verify It's Working

After setup completes, run these commands:

```bash
# Check service status
docker compose ps

# Test backend
curl http://localhost:8000/health

# Test API documentation
curl http://localhost:8000/api/v1/docs
```

**Open in browser:**
- Frontend: http://YOUR_SERVER_IP
- API Docs: http://YOUR_SERVER_IP:8000/api/v1/docs

---

## If You Have Issues

### Cleanup and Try Again

```bash
sudo bash cleanup-only.sh
docker compose build --no-cache
docker compose up -d
```

### Check Logs

```bash
docker compose logs -f backend
```

### Manual Port Cleanup

```bash
# Kill all processes on required ports
sudo fuser -k 8000/tcp 5432/tcp 6379/tcp 80/tcp

# Stop system services
sudo systemctl stop postgresql redis
sudo systemctl disable postgresql redis

# Clean Docker
docker compose down -v
```

---

## Common Commands

```bash
# View logs
docker compose logs -f

# Restart all services
docker compose restart

# Stop all services
docker compose stop

# Start all services
docker compose start

# Rebuild specific service
docker compose build backend
docker compose up -d backend

# Complete cleanup and restart
sudo bash setup.sh
```

---

## What Changed (Fixes Applied)

✅ **docker-compose.yml:**
- Removed obsolete `version:` attribute
- Fixed backend healthcheck (uses Python, not curl)
- Fixed Redis healthcheck (proper authentication)
- Added restart policies
- Increased healthcheck timeouts

✅ **Environment:**
- Service names (postgres, redis) instead of localhost
- All configurations verified

✅ **Automation:**
- `setup.sh` - Full automated deployment
- `cleanup-only.sh` - Cleanup without rebuild
- Port conflict resolution
- Service conflict resolution

---

## Support

For detailed troubleshooting, see: `DEPLOYMENT.md`

For general deployment guide, see: `README.md`
