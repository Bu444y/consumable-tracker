#!/bin/bash

# Consumable Tracker - One-Command VM Installer
# Run on Ubuntu 22.04 VM: curl -sSL https://yourserver/install.sh | bash
# Or download and run: ./one-command-install.sh

set -e

# Configuration
APP_DIR="/opt/consumable-tracker"
GITHUB_REPO=""  # Set this if you have a GitHub repo

echo "========================================="
echo "Consumable Tracker - One-Command Install"
echo "========================================="
echo ""

# Function to check if running as root
check_user() {
    if [ "$EUID" -eq 0 ]; then
        echo "Creating a non-root user for the installation..."
        useradd -m -s /bin/bash appuser
        usermod -aG sudo appuser
        echo "Please set a password for appuser:"
        passwd appuser
        echo "Switching to appuser..."
        su - appuser -c "curl -sSL https://yourserver/install.sh | bash"
        exit 0
    fi
}

# Function to install Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com | sudo sh
        sudo usermod -aG docker $USER
        echo "Docker installed successfully"
        NEED_RELOGIN=true
    fi
}

# Function to install Docker Compose
install_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose installed successfully"
    fi
}

# Function to install Node.js
install_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        echo "Node.js installed successfully"
    fi
}

# Main installation
main() {
    # Check user
    check_user
    
    # Update system
    echo "Updating system packages..."
    sudo apt-get update
    sudo apt-get install -y curl wget git
    
    # Install dependencies
    install_docker
    install_compose
    install_nodejs
    
    # Setup firewall
    echo "Configuring firewall..."
    sudo ufw allow 22/tcp
    sudo ufw allow 3000/tcp
    sudo ufw allow 5000/tcp
    sudo ufw --force enable
    
    # Create application directory
    echo "Setting up application directory..."
    sudo mkdir -p $APP_DIR
    sudo chown $USER:$USER $APP_DIR
    cd $APP_DIR
    
    # Download or create application files
    if [ -n "$GITHUB_REPO" ]; then
        echo "Cloning from GitHub..."
        git clone $GITHUB_REPO .
    else
        echo "Creating application package..."
        create_app_package
    fi
    
    # Check Docker permissions
    if [ "${NEED_RELOGIN}" = "true" ]; then
        echo ""
        echo "======================================"
        echo "Docker installed - RELOGIN REQUIRED"
        echo "======================================"
        echo ""
        echo "Please run these commands:"
        echo ""
        echo "1. Log out and back in:"
        echo "   exit"
        echo ""
        echo "2. Continue installation:"
        echo "   cd $APP_DIR"
        echo "   ./continue-install.sh"
        echo ""
        
        # Create continue script
        cat > continue-install.sh << 'CONTINUE_EOF'
#!/bin/bash
cd /opt/consumable-tracker
chmod +x *.sh
./pre-install.sh
./install.sh
./health-check.sh

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "Installation complete!"
echo "Access at: http://$IP:3000"
CONTINUE_EOF
        chmod +x continue-install.sh
        exit 0
    fi
    
    # If Docker was already installed, continue
    echo "Continuing with installation..."
    chmod +x *.sh
    ./pre-install.sh
    ./install.sh
    
    # Show completion message
    IP=$(hostname -I | awk '{print $1}')
    echo ""
    echo "======================================"
    echo "Installation Complete!"
    echo "======================================"
    echo ""
    echo "Access the application at:"
    echo "http://$IP:3000"
    echo ""
}

# Function to create minimal app package
create_app_package() {
    echo "Creating minimal application files..."
    
    # Create a download instruction file
    cat > SETUP_INSTRUCTIONS.txt << 'EOF'
CONSUMABLE TRACKER - SETUP INSTRUCTIONS
======================================

The base system is now ready. You need to upload the application files.

1. Upload all files from your Windows machine D:/consumable-tracker to this directory:
   /opt/consumable-tracker

2. After uploading, run:
   chmod +x *.sh
   ./pre-install.sh
   ./install.sh

3. Access the application at:
   http://YOUR_VM_IP:3000

For help, see TROUBLESHOOTING.md after uploading files.
EOF

    # Create a minimal docker-compose.yml
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:6
    container_name: consumable-mongo
    restart: unless-stopped
    volumes:
      - mongo-data:/data/db
    ports:
      - "27017:27017"

  backend:
    build: ./backend
    container_name: consumable-backend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - MONGO_URI=mongodb://mongodb:27017/consumable-tracker
      - PORT=5000
    depends_on:
      - mongodb
    ports:
      - "5000:5000"

  frontend:
    build: ./frontend
    container_name: consumable-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "3000:80"

volumes:
  mongo-data:
EOF

    echo ""
    echo "Base files created. See SETUP_INSTRUCTIONS.txt"
}

# Run main installation
main

# Final message if script completes
echo ""
echo "If you see this message, check SETUP_INSTRUCTIONS.txt in $APP_DIR"
