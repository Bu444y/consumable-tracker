#!/bin/bash

# Quick fix script for common Consumable Tracker issues
# This addresses the most common problems in one go

set -e

echo "Consumable Tracker Quick Fix Script"
echo "==================================="
echo ""

# 1. Clean up any existing mess
echo "Step 1: Cleaning up existing containers..."
docker-compose down 2>/dev/null || true
docker rm -f consumable-frontend consumable-backend consumable-mongo 2>/dev/null || true

# 2. Generate package-lock.json files if missing
echo ""
echo "Step 2: Checking package-lock.json files..."
if [ ! -f "./backend/package-lock.json" ] || [ ! -f "./frontend/package-lock.json" ]; then
    echo "Generating missing package-lock.json files..."
    
    if [ ! -f "./backend/package-lock.json" ]; then
        cd backend
        npm install
        cd ..
        echo "✓ Created backend/package-lock.json"
    fi
    
    if [ ! -f "./frontend/package-lock.json" ]; then
        cd frontend
        npm install
        cd ..
        echo "✓ Created frontend/package-lock.json"
    fi
else
    echo "✓ Package-lock.json files exist"
fi

# 3. Clear Docker cache
echo ""
echo "Step 3: Clearing Docker cache..."
docker system prune -f

# 4. Rebuild everything fresh
echo ""
echo "Step 4: Building fresh Docker images..."
docker-compose build --no-cache

# 5. Start services
echo ""
echo "Step 5: Starting services..."
docker-compose up -d

# 6. Wait for services
echo ""
echo "Step 6: Waiting for services to initialize..."
echo -n "MongoDB: "
for i in {1..30}; do
    if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
        echo "✓ Ready"
        break
    fi
    echo -n "."
    sleep 1
done

echo -n "Backend: "
for i in {1..30}; do
    if curl -f -s http://localhost:5000/health &> /dev/null; then
        echo "✓ Ready"
        break
    fi
    echo -n "."
    sleep 1
done

echo -n "Frontend: "
for i in {1..30}; do
    if curl -f -s http://localhost:3000 &> /dev/null; then
        echo "✓ Ready"
        break
    fi
    echo -n "."
    sleep 1
done

# 7. Test API connectivity
echo ""
echo "Step 7: Testing API connectivity..."
if curl -s http://localhost:5000/api/categories | grep -q '\['; then
    echo "✓ API is responding correctly"
else
    echo "✗ API test failed"
    echo "Checking logs..."
    docker-compose logs --tail=20 backend
fi

# 8. Final status
echo ""
echo "==================================="
echo "Quick fix completed!"
echo ""
./health-check.sh

echo ""
echo "If the app still shows 'Failed to load data':"
echo "1. Clear your browser cache (Ctrl+F5)"
echo "2. Try a different browser"
echo "3. Check the browser console (F12) for errors"
echo "4. Run: ./logs.sh to view detailed logs"
echo ""
echo "Access the app at: http://localhost:3000"
