#!/bin/bash

# Fix for npm install issues in Docker
# Run this if you get EAI_AGAIN or DNS errors

echo "Fixing npm/Docker build issues..."
echo "================================="

# 1. Clean up
echo "Cleaning up old containers and images..."
docker-compose down
docker system prune -f

# 2. Remove package-lock files and regenerate
echo "Regenerating package files..."
cd frontend
rm -f package-lock.json
npm install --legacy-peer-deps
cd ..

cd backend
rm -f package-lock.json
npm install
cd ..

# 3. Try building with custom network settings
echo "Building with DNS fixes..."
docker-compose build --no-cache --build-arg DNS_SERVERS="8.8.8.8 8.8.4.4"

# 4. If that fails, try with host network
if [ $? -ne 0 ]; then
    echo "First attempt failed, trying with host network..."
    docker-compose build --no-cache --network host
fi

echo "Build fix completed. Now run: docker-compose up -d"
