#!/bin/bash

# Update script for Consumable Tracker
# Updates the application to the latest version

set -e

echo "Consumable Tracker Update Script"
echo "================================"
echo ""

# Create backup before updating
echo "Creating backup before update..."
if [ -f "./backup.sh" ]; then
    ./backup.sh
else
    echo "Warning: backup.sh not found, skipping backup"
fi

echo ""
echo "Stopping services..."
docker-compose down

echo ""
echo "Pulling latest Docker images..."
docker-compose pull

echo ""
echo "Rebuilding services..."
docker-compose build --no-cache

echo ""
echo "Starting updated services..."
docker-compose up -d

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "Running health check..."
if [ -f "./health-check.sh" ]; then
    ./health-check.sh
else
    echo "Health check script not found"
fi

echo ""
echo "Update completed!"
echo ""
echo "If you encounter any issues:"
echo "1. Check the logs: docker-compose logs -f"
echo "2. Restore from backup: ./restore.sh"
