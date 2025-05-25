TROUBLESHOOTING GUIDE
====================

COMMON ISSUES AND SOLUTIONS:

0. "npm error code EAI_AGAIN" or DNS errors during build
   This is a Docker DNS resolution issue. Solutions:
   
   a) Quick fix:
      ./fix-npm-build.sh
   
   b) Use alternative docker-compose with DNS:
      docker-compose -f docker-compose.dns.yml up -d
   
   c) Use alternative installation (builds locally):
      ./install-alternative.sh
   
   d) Manual fix:
      - Edit /etc/docker/daemon.json on your server:
        {
          "dns": ["8.8.8.8", "8.8.4.4"]
        }
      - Restart Docker: sudo systemctl restart docker
   
   e) If behind corporate proxy:
      - Set Docker proxy settings
      - Use corporate DNS servers instead of 8.8.8.8

1. "npm ci failed" or "Missing package-lock.json"
   Solution:
   - Run: ./pre-install.sh
   - Or manually: cd backend && npm install && cd ../frontend && npm install && cd ..
   - Then run: ./install.sh

2. "Failed to load data. Please try again."
   Possible causes and solutions:
   
   a) Backend not running:
      - Check: docker-compose ps
      - Verify backend is "Up"
      - Check logs: docker-compose logs backend
   
   b) MongoDB connection failed:
      - Check: docker-compose logs mongodb
      - Verify MongoDB is running: docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"
   
   c) Frontend can't reach backend:
      - Test backend directly: curl http://localhost:5000/health
      - Test API: curl http://localhost:5000/api/categories
      - Check browser console for errors (F12)
   
   d) Firewall blocking ports:
      - Ensure ports 3000, 5000, 27017 are open
      - Ubuntu: sudo ufw allow 3000,5000,27017/tcp

3. "Cannot add items/categories"
   - Check browser console for specific errors
   - Verify backend is receiving requests: docker-compose logs -f backend
   - Test API directly: 
     curl -X POST http://localhost:5000/api/categories \
       -H "Content-Type: application/json" \
       -d '{"name":"Test","type":"consumable","icon":"box"}'

4. "Settings page has no back button"
   - This is fixed in the latest version
   - Run: ./update.sh to get the latest code

5. "Docker build fails"
   - Ensure you have enough disk space: df -h
   - Clear Docker cache: docker system prune -a
   - Rebuild: docker-compose build --no-cache

6. "Services won't start after reboot"
   - Run: ./cleanup.sh
   - Then: ./pre-install.sh
   - Finally: ./install.sh

DIAGNOSTIC COMMANDS:

Check all services:
./health-check.sh

View real-time logs:
./logs.sh

Test API endpoints:
# Health check
curl http://localhost:5000/health

# Get categories
curl http://localhost:5000/api/categories

# Test from inside frontend container
docker-compose exec frontend sh -c "wget -O- http://backend:5000/health"

Check Docker networks:
docker network ls
docker network inspect consumable-tracker_app-network

Verify containers can communicate:
docker-compose exec frontend ping backend
docker-compose exec backend ping mongodb

COMPLETE RESET:
If all else fails:
1. ./cleanup.sh
2. ./pre-install.sh
3. ./install.sh

STILL HAVING ISSUES?
1. Collect logs: docker-compose logs > debug.log
2. Check system: uname -a > system.log
3. Docker version: docker --version >> system.log
4. Report issue with logs attached
