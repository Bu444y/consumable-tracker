#!/bin/bash

# Backup script for Consumable Tracker
# Creates timestamped backups of MongoDB data

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="consumable-tracker-backup-${TIMESTAMP}.gz"

echo "Starting backup process..."

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Check if MongoDB container is running
if ! docker-compose ps | grep -q "consumable-mongo.*Up"; then
    echo "Error: MongoDB container is not running"
    exit 1
fi

# Create backup
echo "Creating database backup..."
docker-compose exec -T mongodb mongodump \
    --db consumable-tracker \
    --archive=/tmp/${BACKUP_FILE} \
    --gzip

# Copy backup from container
echo "Copying backup file..."
docker cp consumable-mongo:/tmp/${BACKUP_FILE} ${BACKUP_DIR}/${BACKUP_FILE}

# Remove backup from container
docker-compose exec -T mongodb rm /tmp/${BACKUP_FILE}

# Keep only last 7 backups
echo "Cleaning old backups..."
cd ${BACKUP_DIR}
ls -t consumable-tracker-backup-*.gz 2>/dev/null | tail -n +8 | xargs -r rm

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_FILE}"
echo "Backup size: $(du -h ${BACKUP_FILE} | cut -f1)"

# Optional: List all backups
echo ""
echo "Available backups:"
ls -lh consumable-tracker-backup-*.gz 2>/dev/null || echo "No backups found"
