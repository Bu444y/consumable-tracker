#!/bin/bash

# Reset script for Consumable Tracker
# WARNING: This will delete all data and containers!

set -e

echo "Consumable Tracker Reset Script"
echo "==============================="
echo ""
echo "WARNING: This will:"
echo "- Stop and remove all containers"
echo "- Delete all volumes (including database data)"
echo "- Remove Docker images"
echo ""
echo "This action cannot be undone!"
echo ""

read -p "Are you SURE you want to reset everything? Type 'RESET' to confirm: " confirm

if [ "$confirm" != "RESET" ]; then
    echo "Reset cancelled"
    exit 0
fi

echo ""
echo "Creating final backup before reset..."
if [ -f "./backup.sh" ] && docker-compose ps | grep -q "consumable-mongo.*Up"; then
    ./backup.sh || echo "Backup failed, continuing anyway..."
fi

echo ""
echo "Stopping containers..."
docker-compose down

echo ""
echo "Removing volumes..."
docker-compose down -v

echo ""
echo "Removing images..."
docker-compose down --rmi local

echo ""
echo "Cleaning up Docker system..."
docker system prune -f

echo ""
echo "Reset completed!"
echo ""
echo "To reinstall, run: ./install.sh"
echo "To restore from backup after reinstall, run: ./restore.sh"
