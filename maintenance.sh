#!/bin/bash

# Maintenance script for Consumable Tracker
# Run this periodically (e.g., via cron) for automatic maintenance

set -e

LOG_FILE="./logs/maintenance-$(date +%Y%m%d).log"
mkdir -p ./logs

echo "Starting maintenance: $(date)" >> $LOG_FILE

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    log "ERROR: Services are not running. Skipping maintenance."
    exit 1
fi

# 1. Create backup
log "Creating backup..."
./backup.sh >> $LOG_FILE 2>&1 || log "Backup failed"

# 2. Check disk space
log "Checking disk space..."
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    log "WARNING: Disk usage is high: ${DISK_USAGE}%"
fi

# 3. Clean old logs
log "Cleaning old logs..."
find ./logs -name "maintenance-*.log" -mtime +30 -delete 2>/dev/null || true

# 4. Update consumable amounts based on decrease rates
log "Updating consumable amounts..."
docker-compose exec -T mongodb mongosh consumable-tracker --eval '
db.consumables.find({ decreaseRate: { $gt: 0 } }).forEach(function(item) {
    var now = new Date();
    var lastUpdate = new Date(item.lastUpdated);
    var daysSince = (now - lastUpdate) / (1000 * 60 * 60 * 24);
    
    var decrease = 0;
    if (item.decreaseInterval === "day") {
        decrease = item.decreaseRate * daysSince;
    } else if (item.decreaseInterval === "week") {
        decrease = item.decreaseRate * (daysSince / 7);
    } else if (item.decreaseInterval === "month") {
        decrease = item.decreaseRate * (daysSince / 30);
    }
    
    if (decrease > 0) {
        var newAmount = Math.max(0, item.currentAmount - decrease);
        db.consumables.updateOne(
            { _id: item._id },
            { 
                $set: { 
                    currentAmount: newAmount,
                    lastUpdated: now
                }
            }
        );
        print("Updated " + item.name + ": " + item.currentAmount + " -> " + newAmount);
    }
});
' >> $LOG_FILE 2>&1

# 5. Check for low stock items
log "Checking for low stock items..."
LOW_STOCK_COUNT=$(docker-compose exec -T mongodb mongosh consumable-tracker --quiet --eval '
var count = 0;
db.consumables.find().forEach(function(item) {
    var remaining = (item.currentAmount / item.initialAmount) * 100;
    if (remaining <= item.alertThreshold) {
        count++;
        print(item.name + " is low: " + remaining.toFixed(1) + "%");
    }
});
print("Total low stock items: " + count);
count;
')

if [ $LOW_STOCK_COUNT -gt 0 ]; then
    log "Found $LOW_STOCK_COUNT items with low stock"
fi

# 6. Health check
log "Running health check..."
./health-check.sh >> $LOG_FILE 2>&1 || log "Health check reported issues"

log "Maintenance completed"
echo "Maintenance completed: $(date)" >> $LOG_FILE

# Keep only last 10 maintenance logs
ls -t ./logs/maintenance-*.log 2>/dev/null | tail -n +11 | xargs -r rm

echo "Maintenance completed. Check logs/maintenance-$(date +%Y%m%d).log for details."
