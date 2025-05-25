#!/bin/bash

# Alternative installation using local build
# Use this if Docker npm install keeps failing

echo "Alternative Installation Method"
echo "=============================="

# 1. Build frontend locally
echo "Building frontend locally..."
cd frontend
npm install --legacy-peer-deps
npm run build
cd ..

# 2. Create a simple Dockerfile for frontend
cat > frontend/Dockerfile.simple << 'EOF'
FROM nginx:alpine
COPY build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# 3. Build backend normally
echo "Building backend..."
docker-compose build backend mongodb

# 4. Build frontend with simple Dockerfile
echo "Building frontend with pre-built files..."
docker build -f frontend/Dockerfile.simple -t consumable-tracker_frontend ./frontend

# 5. Start everything
echo "Starting services..."
docker-compose up -d

echo "Alternative installation completed!"
echo "Check status with: ./health-check.sh"
