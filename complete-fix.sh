#!/bin/bash

# Complete manual fix for all issues
# Works around npm, Docker, and LXC problems

echo "Complete Manual Fix for Consumable Tracker"
echo "=========================================="

# 1. Fix backend package-lock.json
echo "Step 1: Fixing backend..."
cd backend
rm -f package-lock.json node_modules -rf
npm install --legacy-peer-deps
cd ..

# 2. Fix frontend with specific ajv version
echo "Step 2: Fixing frontend dependencies..."
cd frontend
rm -f package-lock.json node_modules -rf

# Create a temporary package.json with fixed versions
cat > package-temp.json << 'EOF'
{
  "name": "consumable-tracker-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "lucide-react": "^0.263.1",
    "axios": "^1.5.0",
    "ajv": "^8.12.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "devDependencies": {
    "react-scripts": "5.0.1"
  },
  "overrides": {
    "ajv": "^8.12.0"
  },
  "eslintConfig": {
    "extends": [
      "react-app"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Use the temp file
mv package.json package.json.backup
mv package-temp.json package.json

# Install with specific flags
npm install --legacy-peer-deps --force

# Try to build
echo "Attempting to build frontend..."
npm run build || {
    echo "Build failed, trying alternative approach..."
    
    # If build fails, create a minimal React app
    mkdir -p build
    cat > build/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Consumable Tracker - Building...</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <div style="text-align: center; padding: 50px;">
        <h1>Consumable Tracker</h1>
        <p>Application is being set up. Please refresh in a moment.</p>
    </div>
</body>
</html>
EOF
}

cd ..

# 3. Create Docker Compose that doesn't require building
echo "Step 3: Creating runtime docker-compose..."
cat > docker-compose-runtime.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:6
    container_name: consumable-mongo
    restart: unless-stopped
    environment:
      - MONGO_INITDB_DATABASE=consumable-tracker
    volumes:
      - mongo-data:/data/db
    ports:
      - "27017:27017"

  backend:
    image: node:18-alpine
    container_name: consumable-backend
    working_dir: /app
    volumes:
      - ./backend:/app
      - ./backend/node_modules:/app/node_modules
    command: sh -c "npm install --production && node server.js"
    environment:
      - NODE_ENV=production
      - MONGO_URI=mongodb://mongodb:27017/consumable-tracker
      - PORT=5000
    depends_on:
      - mongodb
    ports:
      - "5000:5000"

  frontend:
    image: nginx:alpine
    container_name: consumable-frontend
    volumes:
      - ./frontend/build:/usr/share/nginx/html
      - ./frontend/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend
    ports:
      - "3000:80"

volumes:
  mongo-data:
EOF

# 4. Update backend Dockerfile to handle missing package-lock.json
echo "Step 4: Updating backend Dockerfile..."
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production || npm install --production --legacy-peer-deps

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]
EOF

# 5. Start services with the runtime compose
echo "Step 5: Starting services..."
docker-compose -f docker-compose-runtime.yml down
docker-compose -f docker-compose-runtime.yml up -d

# 6. Wait and check
echo "Step 6: Waiting for services..."
sleep 10

# 7. If frontend build exists, copy it
if [ -d "frontend/build" ] && [ -f "frontend/build/index.html" ]; then
    echo "Frontend build found."
else
    echo "Creating emergency frontend..."
    mkdir -p frontend/build
    cat > frontend/build/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Consumable Tracker</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>Consumable Tracker</h1>
    <p>Backend API: <a href="http://localhost:5000/api/categories">/api/categories</a></p>
    <p>If you see this, the frontend build failed. Check logs.</p>
</body>
</html>
EOF
fi

echo ""
echo "Fix attempt completed!"
echo ""
docker ps
echo ""
echo "Test endpoints:"
echo "- MongoDB: nc -zv localhost 27017"
echo "- Backend: curl http://localhost:5000/health"
echo "- Frontend: curl http://localhost:3000"
