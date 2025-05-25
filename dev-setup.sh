#!/bin/bash

# Development setup script for Consumable Tracker
# Sets up the application for local development

set -e

echo "Consumable Tracker Development Setup"
echo "===================================="
echo ""

# Check Node.js installation
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

echo "Node.js version: $(node --version)"

# Install backend dependencies
echo ""
echo "Installing backend dependencies..."
cd backend
npm install
cd ..

# Install frontend dependencies
echo ""
echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file..."
    cp .env.example .env
    echo "Please edit .env file with your configuration"
fi

# Start MongoDB container only
echo ""
echo "Starting MongoDB container..."
docker-compose up -d mongodb

echo ""
echo "Waiting for MongoDB to start..."
sleep 5

echo ""
echo "Development setup completed!"
echo ""
echo "To start development servers:"
echo ""
echo "1. Backend (in one terminal):"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo "2. Frontend (in another terminal):"
echo "   cd frontend"
echo "   npm start"
echo ""
echo "MongoDB is running at: localhost:27017"
echo ""
echo "For production deployment, use: ./install.sh"
