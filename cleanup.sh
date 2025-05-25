#!/bin/bash

# Cleanup script for Consumable Tracker
# Removes all containers, volumes, and images

set -e

echo "Consumable Tracker Cleanup Script"
echo "================================="
echo ""
echo "This will remove:"
echo "- All consumable-tracker containers"
echo "- All associated volumes"
echo "- All associated images"
echo ""

read -p "Continue with cleanup? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Stopping containers..."
docker-compose down 2>/dev/null || true

echo "Removing volumes..."
docker volume rm consumable-tracker_mongo-data 2>/dev/null || true

echo "Removing containers..."
docker rm -f consumable-frontend consumable-backend consumable-mongo 2>/dev/null || true

echo "Removing images..."
docker rmi consumable-tracker_frontend consumable-tracker_backend 2>/dev/null || true

echo "Pruning unused Docker resources..."
docker system prune -f

echo ""
echo "Cleanup completed!"
echo ""
echo "To reinstall, run: ./install.sh"
