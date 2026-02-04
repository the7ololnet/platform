#!/bin/bash

echo "========================================="
echo "Port Status Checker"
echo "========================================="
echo ""

PORTS=(8000 5432 6379 80)

for PORT in "${PORTS[@]}"; do
    echo "Port ${PORT}:"
    
    # Check with lsof
    if sudo lsof -i:${PORT} &> /dev/null; then
        echo "  [BUSY] Process using port ${PORT}:"
        sudo lsof -i:${PORT} | grep -v COMMAND
    else
        echo "  [FREE]"
    fi
    
    # Check with netstat
    NETSTAT_OUT=$(sudo netstat -tulpn 2>/dev/null | grep ":${PORT} " || true)
    if [ ! -z "$NETSTAT_OUT" ]; then
        echo "  netstat info:"
        echo "    $NETSTAT_OUT"
    fi
    
    echo ""
done

echo "Docker containers:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  No Docker containers"

echo ""
echo "Docker networks:"
docker network ls --filter name=platform 2>/dev/null || echo "  No Docker networks"

echo ""
echo "System services:"
echo "  PostgreSQL: $(systemctl is-active postgresql 2>/dev/null || echo 'not running')"
echo "  Redis: $(systemctl is-active redis 2>/dev/null || echo 'not running')"

echo ""
