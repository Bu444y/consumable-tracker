#!/bin/bash

# GitHub sync script for Consumable Tracker
# Helps sync changes between local and GitHub

echo "Consumable Tracker - GitHub Sync"
echo "================================"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Git not initialized. Run: git init"
    exit 1
fi

# Function to check for uncommitted changes
check_changes() {
    if ! git diff-index --quiet HEAD --; then
        echo "You have uncommitted changes:"
        git status --short
        return 1
    fi
    return 0
}

# Menu
echo ""
echo "Select an option:"
echo "1) Pull latest from GitHub"
echo "2) Push local changes to GitHub"
echo "3) Check status"
echo "4) Setup GitHub remote"
echo "5) Create .gitignore"
echo ""

read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo "Pulling from GitHub..."
        git pull origin main || git pull origin master
        echo ""
        echo "After pulling, run:"
        echo "  ./pre-install.sh"
        echo "  ./install.sh"
        ;;
    
    2)
        echo "Checking for changes..."
        if check_changes; then
            echo "No changes to commit"
        else
            echo ""
            read -p "Enter commit message: " msg
            git add -A
            git commit -m "$msg"
            git push origin main || git push origin master
            echo "Changes pushed to GitHub!"
        fi
        ;;
    
    3)
        echo "Repository status:"
        git status
        echo ""
        echo "Recent commits:"
        git log --oneline -5
        ;;
    
    4)
        echo "Current remotes:"
        git remote -v
        echo ""
        read -p "Enter GitHub repository URL: " url
        git remote add origin "$url" 2>/dev/null || git remote set-url origin "$url"
        echo "Remote set to: $url"
        ;;
    
    5)
        echo "Creating .gitignore..."
        cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production
build/
dist/

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Docker
docker-compose.override.yml

# Backups
backups/
*.gz
*.tar

# Temporary files
tmp/
temp/

# Package lock files (if you want to exclude them)
# package-lock.json
# yarn.lock
EOF
        echo ".gitignore created!"
        ;;
    
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
