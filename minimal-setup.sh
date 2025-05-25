#!/bin/bash

# Minimal working setup - no builds required
# This uses only pre-built images and bind mounts

echo "Minimal Setup (No Building Required)"
echo "===================================="

# 1. Clean everything
docker stop consumable-mongo consumable-backend consumable-frontend 2>/dev/null
docker rm consumable-mongo consumable-backend consumable-frontend 2>/dev/null

# 2. Prepare backend for direct running
cd backend
echo "Installing backend dependencies..."
npm install --production --legacy-peer-deps --no-audit --no-fund
cd ..

# 3. Prepare minimal frontend
cd frontend
if [ ! -d "build" ]; then
    echo "Creating minimal frontend..."
    mkdir -p build
    
    # Create a working minimal React app
    cat > build/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Consumable Tracker</title>
    <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; }
        .container { padding: 20px; max-width: 800px; margin: 0 auto; }
        .error { color: red; padding: 10px; background: #ffe0e0; border-radius: 5px; }
        .success { color: green; padding: 10px; background: #e0ffe0; border-radius: 5px; }
        .item { padding: 10px; margin: 5px 0; background: #f0f0f0; border-radius: 5px; }
    </style>
</head>
<body>
    <div id="root"></div>
    <script>
        const { useState, useEffect } = React;
        const API_URL = '/api';
        
        function App() {
            const [status, setStatus] = useState('Loading...');
            const [error, setError] = useState(null);
            
            useEffect(() => {
                // Test API connection
                axios.get(API_URL + '/categories')
                    .then(res => {
                        setStatus('API Connected! Categories: ' + res.data.length);
                        setError(null);
                    })
                    .catch(err => {
                        setError('API Error: ' + err.message);
                        setStatus('Failed to connect');
                    });
            }, []);
            
            return React.createElement('div', { className: 'container' },
                React.createElement('h1', null, 'Consumable Tracker'),
                React.createElement('p', null, 'Status: ' + status),
                error && React.createElement('div', { className: 'error' }, error),
                React.createElement('p', null, 'This is a minimal UI. The full app needs to be built.'),
                React.createElement('a', { href: API_URL + '/categories' }, 'Test API Endpoint')
            );
        }
        
        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(React.createElement(App));
    </script>
</body>
</html>
EOF
fi
cd ..

# 4. Start everything with simple docker run commands
echo "Starting services..."

# MongoDB
docker run -d \
    --name consumable-mongo \
    -p 27017:27017 \
    --restart unless-stopped \
    mongo:6

# Wait for MongoDB
echo "Waiting for MongoDB..."
sleep 5

# Backend - run directly with Node
docker run -d \
    --name consumable-backend \
    -p 5000:5000 \
    -v $(pwd)/backend:/app \
    -w /app \
    --link consumable-mongo:mongodb \
    -e NODE_ENV=production \
    -e MONGO_URI=mongodb://mongodb:27017/consumable-tracker \
    -e PORT=5000 \
    --restart unless-stopped \
    node:18-alpine \
    node server.js

# Frontend - nginx
docker run -d \
    --name consumable-frontend \
    -p 3000:80 \
    -v $(pwd)/frontend/build:/usr/share/nginx/html:ro \
    -v $(pwd)/frontend/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
    --link consumable-backend:backend \
    --restart unless-stopped \
    nginx:alpine

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "Checking status..."
docker ps

echo ""
echo "Testing endpoints..."
echo -n "MongoDB: "
nc -zv localhost 27017 2>&1 | grep -q succeeded && echo "✓ Connected" || echo "✗ Failed"

echo -n "Backend: "
curl -s http://localhost:5000/health | grep -q healthy && echo "✓ Healthy" || echo "✗ Failed"

echo -n "Frontend: "
curl -s http://localhost:3000 | grep -q "<title>" && echo "✓ Serving" || echo "✗ Failed"

echo ""
echo "If all services show ✓, the app is running!"
echo "Access at: http://localhost:3000"
echo ""
echo "To see logs:"
echo "  docker logs consumable-backend"
echo "  docker logs consumable-frontend"
