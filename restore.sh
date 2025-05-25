#!/bin/bash

# Restore script for Consumable Tracker
# Restores MongoDB data from a backup file

set -e

BACKUP_DIR="./backups"

echo "Consumable Tracker Restore Script"
echo "================================="

# Check if MongoDB container is running
if ! docker-compose ps | grep -q "consumable-mongo.*Up"; then
    echo "Error: MongoDB container is not running"
    exit 1
fi

# List available backups
echo "Available backups:"
echo ""
if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A $BACKUP_DIR/*.gz 2>/dev/null)" ]; then
    ls -1 $BACKUP_DIR/*.gz | nl -v 0
else
    echo "No backups found in $BACKUP_DIR"
    exit 1
fi

# Prompt for backup selection
echo ""
read -p "Enter the number of the backup to restore (or 'q' to quit): " selection

if [ "$selection" == "q" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Get the selected backup file
BACKUP_FILE=$(ls -1 $BACKUP_DIR/*.gz | sed -n "$((selection+1))p")

if [ -z "$BACKUP_FILE" ]; then
    echo "Invalid selection"
    exit 1
fi

echo ""
echo "Selected backup: $(basename $BACKUP_FILE)"
echo ""
echo "WARNING: This will replace all current data!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Copy backup to container
echo "Copying backup file to container..."
docker cp "$BACKUP_FILE" consumable-mongo:/tmp/restore.gz

# Restore the backup
echo "Restoring database..."
docker-compose exec -T mongodb mongorestore \
    --db consumable-tracker \
    --archive=/tmp/restore.gz \
    --gzip \
    --drop

# Clean up
docker-compose exec -T mongodb rm /tmp/restore.gz

echo ""
echo "Restore completed successfully!"
echo "You may need to refresh your browser to see the restored data."
