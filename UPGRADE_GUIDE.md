UPGRADE GUIDE - v1.0 to v1.1
============================

This guide helps you upgrade from the original version to the new version with all fixes.

BEFORE YOU START:
1. Backup your data: ./backup.sh
2. Note down any important consumables/tasks
3. Stop the current version: docker-compose down

UPGRADE STEPS:

1. BACKUP CURRENT DATA
   ```bash
   cd /opt/consumable-tracker
   ./backup.sh
   # Note the backup filename
   ```

2. SYNC WITH GITHUB
   ```bash
   # Save any local changes
   git stash
   
   # Pull latest changes
   git pull origin main
   
   # Apply local changes if any
   git stash pop
   ```

3. CLEAN OLD CONTAINERS
   ```bash
   # Stop everything
   docker-compose down
   
   # Remove old images
   docker rmi consumable-tracker_frontend consumable-tracker_backend
   
   # Clean volumes (WARNING: This removes data)
   # docker volume rm consumable-tracker_mongo-data
   ```

4. REBUILD WITH NEW VERSION
   ```bash
   # Install dependencies
   ./pre-install.sh
   
   # Build and start
   ./install.sh
   ```

5. VERIFY INSTALLATION
   ```bash
   # Check health
   ./health-check.sh
   
   # Check logs
   docker-compose logs -f
   ```

6. ADD SAMPLE DATA (Optional)
   ```bash
   # Add test items to verify everything works
   ./add-sample-data.sh
   ```

DATA MIGRATION:

The new version uses a different schema. Your old data won't appear automatically.

Option 1: Manual Re-entry
- Use the UI to re-add your consumables with proper units
- Re-create your tasks

Option 2: Use Migration Script (if available)
```bash
# Not yet implemented
# ./migrate-data.sh backup-file.gz
```

NEW FEATURES TO CONFIGURE:

1. UNITS
   - Edit each consumable to set proper units (lbs, oz, count, etc.)
   - Adjust decrease rates for the new unit system

2. DARK MODE
   - Click the sun/moon icon in the top bar

3. VIEWS
   - Try the new "All Consumables" and "All Tasks" views
   - Switch between Grid and List views

4. AUTO-DECREASE
   - Runs hourly automatically
   - Force run from Settings if needed

TROUBLESHOOTING:

If you see "Failed to load data":
1. Clear browser cache (Ctrl+F5)
2. Check API: curl http://localhost:5000/health
3. Check logs: docker-compose logs backend

If items don't decrease automatically:
1. Check if decrease rate is set
2. Force auto-decrease from Settings
3. Check logs for auto-decrease messages

If dark mode doesn't work:
1. Clear browser cache
2. Check browser console for errors
3. Try a different browser

ROLLBACK IF NEEDED:

To rollback to the previous version:
```bash
# Stop new version
docker-compose down

# Restore old code
git checkout <previous-commit-hash>

# Restore data
./restore.sh

# Start old version
docker-compose up -d
```

HELP:

- Check UPDATE_SUMMARY.md for all changes
- See TROUBLESHOOTING.md for common issues
- Check logs: ./logs.sh
- API test: ./test-api.sh

Remember: The new version is much better! The upgrade is worth it for:
- Proper units (no more percentages!)
- Working auto-decrease
- Dark mode
- Better views and sorting
- Fixed recurring tasks
