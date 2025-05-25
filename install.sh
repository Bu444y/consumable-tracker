#!/bin/bash

# Consumable Tracker Installation Script
# This script sets up the Consumable Tracker application using Docker

set -e

echo "======================================"
echo "Consumable Tracker Installation Script"
echo "======================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"

# Check for package-lock.json files
if [ ! -f "./backend/package-lock.json" ] || [ ! -f "./frontend/package-lock.json" ]; then
    echo "Missing package-lock.json files detected."
    echo "Please run: ./pre-install.sh first"
    echo "Or manually run 'npm install' in both backend/ and frontend/ directories"
    exit 1
fi

# Stop any existing containers
echo "Stopping any existing containers..."
docker-compose down 2>/dev/null || true

# Create necessary directories
echo "Creating directories..."
mkdir -p backend/models backend/routes
mkdir -p frontend/src/components frontend/src/services frontend/public

# Build and start the containers
echo "Building Docker images..."
docker-compose build

echo "Starting containers..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check if services are running
echo "Checking service health..."

# Check MongoDB
if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
    echo "✓ MongoDB is running"
else
    echo "✗ MongoDB failed to start"
    exit 1
fi

# Check Backend
if curl -f http://localhost:5000/health &> /dev/null; then
    echo "✓ Backend API is running"
else
    echo "✗ Backend API failed to start"
    exit 1
fi

# Check Frontend
if curl -f http://localhost:3000 &> /dev/null; then
    echo "✓ Frontend is running"
else
    echo "✗ Frontend failed to start"
    exit 1
fi

echo ""
echo "======================================"
echo "Installation completed successfully!"
echo "======================================"
echo ""
echo "Access the application at: http://localhost:3000"
echo "API endpoint: http://localhost:5000/api"
echo "MongoDB: localhost:27017"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo "To restart: docker-compose restart"
echo ""
echo "Default categories have been created automatically."
echo "You can start adding consumables and tasks right away!"
