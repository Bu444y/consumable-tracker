#!/bin/bash

# LXC-friendly installation without Docker builds
# This runs everything directly without complex Docker builds

echo "LXC-Friendly Installation (No Docker Builds)"
echo "==========================================="

# 1. Check if we're in LXC
if [ -f /proc/1/environ ] && grep -q lxc /proc/1/environ; then
    echo "Detected LXC environment"
fi

# 2. Install Node.js if needed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 3. Run MongoDB in Docker (simple, no build needed)
echo "Starting MongoDB..."
docker run -d \
    --name consumable-mongo \
    -p 27017:27017 \
    -v mongo-data:/data/db \
    -e MONGO_INITDB_DATABASE=consumable-tracker \
    --restart unless-stopped \
    mongo:6

# 4. Install and run backend directly (no Docker)
echo "Setting up backend..."
cd backend
npm install --production --legacy-peer-deps
nohup node server.js > backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend started with PID: $BACKEND_PID"
cd ..

# 5. Build frontend locally
echo "Building frontend..."
cd frontend

# Fix the ajv issue by installing specific version
npm uninstall ajv ajv-keywords --save
npm install ajv@8.12.0 --save --legacy-peer-deps
npm install --legacy-peer-deps --force

# Try to build
npm run build || {
    echo "Build failed, creating static fallback..."
    mkdir -p build
    cp ../frontend-static/* build/ 2>/dev/null || true
}
cd ..

# 6. Run nginx for frontend
echo "Starting frontend..."
docker run -d \
    --name consumable-frontend \
    -p 3000:80 \
    -v $(pwd)/frontend/build:/usr/share/nginx/html:ro \
    -v $(pwd)/frontend/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
    --restart unless-stopped \
    nginx:alpine

# 7. Create systemd service for backend (optional)
echo "Creating systemd service..."
sudo tee /etc/systemd/system/consumable-backend.service > /dev/null << EOF
[Unit]
Description=Consumable Tracker Backend
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/consumable-tracker/backend
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=NODE_ENV=production
Environment=MONGO_URI=mongodb://localhost:27017/consumable-tracker
Environment=PORT=5000

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "Installation completed!"
echo ""
echo "Services status:"
docker ps
echo ""
echo "Backend process: ps aux | grep 'node server.js'"
ps aux | grep 'node server.js' | grep -v grep
echo ""
echo "To use systemd service instead of nohup:"
echo "  sudo systemctl enable consumable-backend"
echo "  sudo systemctl start consumable-backend"
echo ""
echo "Test with:"
echo "  curl http://localhost:5000/health"
echo "  curl http://localhost:3000"
