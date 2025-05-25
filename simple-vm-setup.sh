#!/bin/bash

# Consumable Tracker - Simple VM Setup for Ubuntu 22.04
# This is the easiest way to get started on a fresh VM

set -e

echo "======================================"
echo "Consumable Tracker - Simple VM Setup"
echo "======================================"
echo ""

# Check not root
if [ "$EUID" -eq 0 ]; then
    echo "Please run as regular user, not root"
    exit 1
fi

# Variables
NEED_RELOGIN=false

# 1. Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
    NEED_RELOGIN=true
    echo "✓ Docker installed"
else
    echo "✓ Docker already installed"
fi

# 2. Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✓ Docker Compose installed"
else
    echo "✓ Docker Compose already installed"
fi

# 3. Install Node.js
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    # Download and run setup script with sudo
    curl -fsSL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt-get install -y nodejs
    rm nodesource_setup.sh
    echo "✓ Node.js installed"
else
    echo "✓ Node.js already installed"
fi

# 4. Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp  
sudo ufw allow 5000/tcp
sudo ufw --force enable
echo "✓ Firewall configured"

# 5. Create directory
echo "Creating application directory..."
sudo mkdir -p /opt/consumable-tracker
sudo chown $USER:$USER /opt/consumable-tracker
cd /opt/consumable-tracker

# 6. Check if need to relogin
if [ "$NEED_RELOGIN" = true ]; then
    cat > /opt/consumable-tracker/continue-setup.sh << 'CONTINUE'
#!/bin/bash
echo "Continuing Consumable Tracker setup..."
cd /opt/consumable-tracker

# Upload instructions
echo ""
echo "======================================"
echo "MANUAL STEP REQUIRED"
echo "======================================"
echo ""
echo "Please upload all files from your Windows machine"
echo "FROM: D:/consumable-tracker"
echo "TO:   /opt/consumable-tracker"
echo ""
echo "Use WinSCP or similar to upload the files"
echo ""
echo "After uploading all files, run:"
echo "  chmod +x *.sh"
echo "  ./pre-install.sh"
echo "  ./install.sh"
echo ""
IP=$(hostname -I | awk '{print $1}')
echo "The app will be available at: http://$IP:3000"
CONTINUE
    chmod +x /opt/consumable-tracker/continue-setup.sh
    
    echo ""
    echo "======================================"
    echo "RELOGIN REQUIRED"
    echo "======================================"
    echo ""
    echo "Docker was installed. You must log out and back in."
    echo ""
    echo "Run these commands:"
    echo "  exit"
    echo "  [SSH back into the VM]"
    echo "  cd /opt/consumable-tracker"
    echo "  ./continue-setup.sh"
    echo ""
    exit 0
fi

# 7. If Docker already worked, show upload instructions
echo ""
echo "======================================"
echo "READY FOR APPLICATION FILES"
echo "======================================"
echo ""
echo "System is ready! Now upload your application files:"
echo ""
echo "1. Use WinSCP to connect to this VM"
echo "2. Navigate to: /opt/consumable-tracker"
echo "3. Upload ALL files from: D:/consumable-tracker"
echo "4. After upload, run these commands:"
echo ""
echo "   cd /opt/consumable-tracker"
echo "   chmod +x *.sh"
echo "   ./pre-install.sh"
echo "   ./install.sh"
echo ""
IP=$(hostname -I | awk '{print $1}')
echo "Your VM IP: $IP"
echo "App will be at: http://$IP:3000"
echo ""

# Create a reminder file
cat > NEXT_STEPS.txt << 'STEPS'
CONSUMABLE TRACKER - NEXT STEPS
===============================

1. Upload all files from D:/consumable-tracker to this directory

2. Run these commands:
   chmod +x *.sh
   ./pre-install.sh
   ./install.sh

3. Access the app at http://YOUR_IP:3000

If you have issues:
- Run: ./quick-fix.sh
- Check: ./health-check.sh
- See: TROUBLESHOOTING.md (after upload)
STEPS

echo "Instructions saved to: NEXT_STEPS.txt"
