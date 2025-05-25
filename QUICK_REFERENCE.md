CONSUMABLE TRACKER - QUICK REFERENCE
====================================

COMMON TASKS:

Start/Stop Application:
  Start:    docker-compose up -d
  Stop:     docker-compose down
  Restart:  docker-compose restart
  Status:   docker-compose ps

View Logs:
  All:      ./logs.sh
  Live:     docker-compose logs -f
  Backend:  docker-compose logs backend
  Frontend: docker-compose logs frontend

Backup/Restore:
  Backup:   ./backup.sh
  Restore:  ./restore.sh
  List:     ls -la backups/

Updates:
  Update:   ./update.sh
  Check:    ./health-check.sh

Troubleshooting:
  Health:   ./health-check.sh
  API Test: curl http://localhost:5000/health
  Logs:     ./logs.sh
  Reset:    ./cleanup.sh && ./install.sh

DATABASE OPERATIONS:

Connect to MongoDB:
  docker-compose exec mongodb mongosh consumable-tracker

View Collections:
  show collections
  db.consumables.find()
  db.tasks.find()
  db.categories.find()

Force Auto-Decrease:
  curl -X POST http://localhost:5000/api/consumables/auto-decrease

KEYBOARD SHORTCUTS:

In Application:
  Dark Mode: Click sun/moon icon
  View Mode: Click grid/list icon
  Add Item:  Click + button
  Decrease:  Click - button
  Refill:    Click ↻ button

COMMON FIXES:

"Failed to load data":
  1. Clear browser cache (Ctrl+F5)
  2. Check backend: docker logs consumable-backend
  3. Restart: docker-compose restart

Items not decreasing:
  1. Check decrease rate is set
  2. Force decrease from Settings
  3. Check: docker logs consumable-backend | grep decrease

Dark mode not working:
  1. Clear browser cache
  2. Check localStorage in console
  3. Try incognito mode

Permission errors (VM):
  1. sudo chown -R $USER:$USER /opt/consumable-tracker
  2. Log out and back in for Docker group
  3. newgrp docker

USEFUL COMMANDS:

Test API endpoints:
  Categories: curl http://localhost:5000/api/categories
  Consumables: curl http://localhost:5000/api/consumables
  Tasks: curl http://localhost:5000/api/tasks

Add test data:
  ./add-sample-data.sh

Check disk usage:
  docker system df
  du -sh /opt/consumable-tracker

Clean Docker:
  docker system prune -a

DEFAULT CREDENTIALS:
  No login required - single user system
  MongoDB: No auth (local only)
  API: No auth (local only)

PORTS:
  3000 - Frontend (React)
  5000 - Backend API (Express)
  27017 - MongoDB

URLs:
  Application: http://localhost:3000
  API Docs: http://localhost:5000
  Health: http://localhost:5000/health

SUPPORT:
  GitHub: https://github.com/Bu444y/consumable-tracker
  Issues: Check TROUBLESHOOTING.md
  Updates: Check UPDATE_SUMMARY.md
