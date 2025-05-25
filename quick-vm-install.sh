#!/bin/bash

# Consumable Tracker - Quick VM Install Script
# This script sets up everything on a fresh Ubuntu 22.04 VM with one command
# Just run: bash quick-vm-install.sh

set -e

echo "========================================"
echo "Consumable Tracker - Quick VM Install"
echo "========================================"
echo ""

# Quick check
if [ "$EUID" -eq 0 ]; then
    echo "Please run as normal user, not root. Script will use sudo when needed."
    exit 1
fi

# Install Docker if needed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed!"
fi

# Install Docker Compose if needed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install Node.js if needed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Create app directory
echo "Creating application directory..."
sudo mkdir -p /opt/consumable-tracker
sudo chown $USER:$USER /opt/consumable-tracker
cd /opt/consumable-tracker

# Check if files already exist
if [ -f "docker-compose.yml" ]; then
    echo "Application files already exist."
    read -p "Remove existing files and reinstall? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf *
    else
        echo "Aborted."
        exit 1
    fi
fi

echo "Downloading application package..."

# Create a temporary script to download from GitHub or your server
cat > download-files.sh << 'DOWNLOAD_SCRIPT'
#!/bin/bash

# Option 1: If you have the files on a web server
# wget -O consumable-tracker.tar.gz https://your-server.com/consumable-tracker.tar.gz
# tar -xzf consumable-tracker.tar.gz
# rm consumable-tracker.tar.gz

# Option 2: Manual message
echo ""
echo "======================================"
echo "MANUAL STEP REQUIRED"
echo "======================================"
echo ""
echo "Please upload all files from D:/consumable-tracker to:"
echo "/opt/consumable-tracker"
echo ""
echo "You can use WinSCP or similar to upload the files."
echo ""
echo "After uploading, run:"
echo "  cd /opt/consumable-tracker"
echo "  chmod +x *.sh"
echo "  ./pre-install.sh"
echo "  ./install.sh"
echo ""
echo "Or for automated setup after upload, run:"
echo "  ./finish-vm-setup.sh"
DOWNLOAD_SCRIPT

chmod +x download-files.sh

# Create finish setup script
cat > finish-vm-setup.sh << 'FINISH_SCRIPT'
#!/bin/bash

set -e

echo "Finishing VM setup..."

# Make all scripts executable
chmod +x *.sh

# Fix Docker permissions if needed
if ! groups | grep -q docker; then
    echo "You need to log out and back in for Docker permissions."
    echo "Or run: newgrp docker"
    echo "Then run this script again."
    exit 1
fi

# Pre-install
if [ -f "./pre-install.sh" ]; then
    echo "Running pre-install..."
    ./pre-install.sh
else
    echo "pre-install.sh not found. Trying manual npm install..."
    (cd backend && npm install)
    (cd frontend && npm install --legacy-peer-deps)
fi

# Main install
if [ -f "./install.sh" ]; then
    echo "Running main installation..."
    ./install.sh
else
    echo "install.sh not found. Using docker-compose directly..."
    docker-compose up -d
fi

# Wait for services
echo "Waiting for services to start..."
sleep 15

# Health check
if [ -f "./health-check.sh" ]; then
    ./health-check.sh
else
    echo "Checking services manually..."
    docker-compose ps
fi

# Get IP
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Access the application at:"
echo "http://$IP:3000"
echo ""
echo "API endpoint:"
echo "http://$IP:5000/api"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo "To restart: docker-compose restart"
FINISH_SCRIPT

chmod +x finish-vm-setup.sh

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 5000/tcp
sudo ufw --force enable

# Show next steps
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "======================================"
echo "Quick VM Install - Phase 1 Complete"
echo "======================================"
echo ""
echo "Docker installed: $(docker --version 2>/dev/null || echo 'Need to relogin')"
echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo 'Installed')"
echo "Node.js: $(node --version)"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. If you just installed Docker, log out and back in:"
echo "   exit"
echo "   ssh back into the VM"
echo ""
echo "2. Upload all files from your Windows machine to:"
echo "   /opt/consumable-tracker"
echo ""
echo "3. Run the finish script:"
echo "   cd /opt/consumable-tracker"
echo "   ./finish-vm-setup.sh"
echo ""
echo "VM IP: $IP"
echo "App will be at: http://$IP:3000"
echo ""

# Check if need to relogin for Docker
if ! groups | grep -q docker; then
    echo "IMPORTANT: You must log out and back in before continuing!"
fi
