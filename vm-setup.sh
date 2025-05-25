#!/bin/bash

# Consumable Tracker - Complete VM Setup Script
# Run this on a fresh Ubuntu 22.04 VM to install everything from scratch
# Usage: curl -sSL https://your-server/vm-setup.sh | bash
# Or: ./vm-setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

echo "=============================================="
echo "Consumable Tracker - Complete VM Setup"
echo "=============================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user, not root"
    print_info "The script will use sudo when needed"
    exit 1
fi

# Check Ubuntu version
if ! grep -q "Ubuntu 22.04" /etc/os-release; then
    print_info "Warning: This script is designed for Ubuntu 22.04"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
print_info "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install prerequisites
print_info "Installing prerequisites..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    htop

# Install Docker
print_info "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    print_status "Docker installed successfully"
else
    print_status "Docker already installed"
fi

# Install Docker Compose standalone (for compatibility)
print_info "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION="v2.24.1"
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_status "Docker Compose installed successfully"
else
    print_status "Docker Compose already installed"
fi

# Install Node.js (for pre-install script)
print_info "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_status "Node.js installed successfully"
else
    print_status "Node.js already installed"
fi

# Configure firewall
print_info "Configuring firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 5000/tcp  # Backend API
sudo ufw allow 27017/tcp # MongoDB (only if needed externally)
sudo ufw --force enable
print_status "Firewall configured"

# Create application directory
print_info "Setting up application directory..."
sudo mkdir -p /opt/consumable-tracker
sudo chown $USER:$USER /opt/consumable-tracker
cd /opt/consumable-tracker

# Download application files
print_info "Downloading application files..."
if [ -d ".git" ]; then
    print_status "Application files already exist, pulling updates..."
    git pull
else
    # Create all necessary files
    print_info "Creating application structure..."
    
    # Create directory structure
    mkdir -p backend/models backend/routes
    mkdir -p frontend/src/components frontend/src/services frontend/public

    # We'll need to download or create all files here
    # For now, we'll create a download script
    cat > download-app.sh << 'DOWNLOAD_EOF'
#!/bin/bash
# This script should download all application files
# In production, this would download from your repository

echo "Application files need to be uploaded to this directory:"
echo "/opt/consumable-tracker"
echo ""
echo "Please upload all files from your Windows machine to this directory"
echo "Then run: ./setup-continue.sh"
DOWNLOAD_EOF
    chmod +x download-app.sh
    
    # Create continuation script
    cat > setup-continue.sh << 'CONTINUE_EOF'
#!/bin/bash
# Continue setup after files are uploaded

set -e

echo "Continuing Consumable Tracker setup..."

# Make all scripts executable
chmod +x *.sh

# Generate package-lock.json files
./pre-install.sh

# Run main installation
./install.sh

# Run health check
./health-check.sh

echo ""
echo "Setup completed!"
echo "Access the application at: http://$(hostname -I | awk '{print $1}'):3000"
CONTINUE_EOF
    chmod +x setup-continue.sh
fi

# Create systemd service for auto-start
print_info "Creating systemd service..."
sudo tee /etc/systemd/system/consumable-tracker.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=Consumable Tracker Docker Compose Application
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=YOUR_USER
WorkingDirectory=/opt/consumable-tracker
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
ExecReload=/usr/local/bin/docker-compose restart
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Replace YOUR_USER with actual user
sudo sed -i "s/YOUR_USER/$USER/g" /etc/systemd/system/consumable-tracker.service
sudo systemctl daemon-reload
print_status "Systemd service created"

# Create update script
print_info "Creating update script..."
cat > /opt/consumable-tracker/update-system.sh << 'UPDATE_EOF'
#!/bin/bash
# System update script

echo "Updating Consumable Tracker..."
cd /opt/consumable-tracker

# Stop services
docker-compose down

# Update application
git pull || echo "Manual file update needed"

# Rebuild and restart
./update.sh

echo "Update completed!"
UPDATE_EOF
chmod +x /opt/consumable-tracker/update-system.sh

# Create backup cron job
print_info "Setting up automatic backups..."
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/consumable-tracker/backup.sh") | crontab -

# Final instructions
echo ""
echo "=============================================="
echo "VM Setup Completed!"
echo "=============================================="
echo ""
print_status "Docker: $(docker --version)"
print_status "Docker Compose: $(docker-compose --version)"
print_status "Node.js: $(node --version)"
print_status "NPM: $(npm --version)"
echo ""
echo "IMPORTANT: You need to log out and back in for Docker permissions to take effect"
echo ""
echo "Next steps:"
echo "1. Log out and back in (or run: newgrp docker)"
echo "2. Upload application files to /opt/consumable-tracker"
echo "3. Run: cd /opt/consumable-tracker && ./setup-continue.sh"
echo ""
echo "To enable auto-start on boot:"
echo "  sudo systemctl enable consumable-tracker"
echo ""
echo "VM IP address: $(hostname -I | awk '{print $1}')"
echo "The application will be available at: http://$(hostname -I | awk '{print $1}'):3000"
echo ""

# Reminder to relogin
if ! groups | grep -q docker; then
    print_info "Please log out and back in to use Docker without sudo"
fi
