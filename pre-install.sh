#!/bin/bash

# Pre-install script to generate package-lock.json files
# Works properly with non-root users on VMs

set -e

echo "Generating package-lock.json files..."

# Check if we have write permissions
if [ ! -w "." ]; then
    echo "Error: No write permission in current directory"
    echo "Run: sudo chown -R $USER:$USER ."
    exit 1
fi

# Backend
if [ ! -f "./backend/package-lock.json" ]; then
    echo "Creating backend/package-lock.json..."
    cd backend
    rm -rf node_modules 2>/dev/null || true
    npm install --no-audit --no-fund
    cd ..
    echo "✓ Backend dependencies installed"
else
    echo "✓ backend/package-lock.json already exists"
fi

# Frontend
if [ ! -f "./frontend/package-lock.json" ]; then
    echo "Creating frontend/package-lock.json..."
    cd frontend
    rm -rf node_modules 2>/dev/null || true
    npm install --legacy-peer-deps --no-audit --no-fund
    cd ..
    echo "✓ Frontend dependencies installed"
else
    echo "✓ frontend/package-lock.json already exists"
fi

echo ""
echo "Package lock files generated successfully!"
echo ""
echo "Next step: ./install.sh"
