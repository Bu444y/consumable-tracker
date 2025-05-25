#!/bin/bash

# Health check script for Consumable Tracker
# Checks the status of all services

set -e

echo "Consumable Tracker Health Check"
echo "==============================="
echo ""

# Function to check service
check_service() {
    local service=$1
    local url=$2
    local name=$3
    
    echo -n "Checking $name... "
    
    if curl -f -s -o /dev/null "$url"; then
        echo "✓ OK"
        return 0
    else
        echo "✗ FAILED"
        return 1
    fi
}

# Check if containers are running
echo "Container Status:"
echo "-----------------"
docker-compose ps

echo ""
echo "Service Health:"
echo "---------------"

# Check MongoDB
echo -n "MongoDB... "
if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
    echo "✓ OK"
    MONGO_STATUS=0
else
    echo "✗ FAILED"
    MONGO_STATUS=1
fi

# Check Backend API
check_service "backend" "http://localhost:5000/health" "Backend API"
BACKEND_STATUS=$?

# Check Frontend
check_service "frontend" "http://localhost:3000" "Frontend"
FRONTEND_STATUS=$?

# Check API endpoints
echo ""
echo "API Endpoints:"
echo "--------------"
check_service "categories" "http://localhost:5000/api/categories" "Categories API"
check_service "consumables" "http://localhost:5000/api/consumables" "Consumables API"
check_service "tasks" "http://localhost:5000/api/tasks" "Tasks API"

# Memory and disk usage
echo ""
echo "Resource Usage:"
echo "---------------"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep consumable || true

# Overall status
echo ""
echo "Overall Status:"
echo "---------------"
if [ $MONGO_STATUS -eq 0 ] && [ $BACKEND_STATUS -eq 0 ] && [ $FRONTEND_STATUS -eq 0 ]; then
    echo "✓ All services are healthy!"
    echo ""
    echo "Access the application at: http://localhost:3000"
    exit 0
else
    echo "✗ Some services are not healthy. Check the logs:"
    echo "  docker-compose logs -f"
    exit 1
fi
