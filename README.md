# Consumable Tracker

A self-hosted web application for tracking household consumables and recurring tasks. Built with React, Node.js, Express, and MongoDB.

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

### Consumable Tracking
- **Multiple Units**: Track items in count, lbs, oz, kg, g, l, ml, or percent
- **Automatic Depletion**: Set decrease rates per day/week/month
- **Empty Date Predictions**: See when items will run out
- **Low Stock Alerts**: Visual indicators when items are running low
- **Quick Actions**: Decrease by 1 unit or refill with one click
- **Notes & Images**: Add details and image URLs to items

### Task Management
- **Recurring Tasks**: Daily, weekly, monthly, or custom schedules
- **Smart Recurrence**: Tasks reschedule automatically when completed
- **Priority Levels**: High, medium, low with color coding
- **Due Date Tracking**: Never miss important tasks
- **Single Entry**: No duplicate tasks cluttering your list

### User Interface
- **Dark Mode**: Toggle between light and dark themes
- **Multiple Views**: Grid or list layouts
- **All Items View**: See everything across all categories
- **Sorting Options**: By name, quantity, date, or priority
- **Mobile Responsive**: Works on all devices
- **Real-time Updates**: See changes instantly

### Organization
- **Custom Categories**: Organize by room or type
- **Color Coding**: Visual organization
- **Collapsible Sidebar**: More space on mobile

## Screenshots

[Add screenshots here]

## Prerequisites

- Docker and Docker Compose installed on your system
- Ports 3000, 5000, and 27017 available

## Installation

1. Clone or download this repository to your server:
```bash
git clone <repository-url>
cd consumable-tracker
```

2. Make the install script executable:
```bash
chmod +x install.sh
```

3. Run the installation:
```bash
./install.sh
```

The script will:
- Build the Docker images
- Start all services (MongoDB, Backend API, Frontend)
- Verify services are running correctly
- Create default categories

## Accessing the Application

- **Web Interface**: http://localhost:3000
- **API Endpoint**: http://localhost:5000/api
- **MongoDB**: localhost:27017

## Default Categories

The application comes with pre-configured categories:

**Consumables:**
- Kitchen
- Bathroom
- Cleaning

**Tasks:**
- Home
- Yard
- Maintenance

You can add custom categories through the application interface.

## Usage

### Managing Consumables
1. Click on a consumable category (Kitchen, Bathroom, etc.)
2. Click "Add Item" to track a new consumable
3. Set the initial amount, decrease rate, and alert threshold
4. Use the decrease/refill buttons to update quantities

### Managing Tasks
1. Click on a task category (Home, Yard, etc.)
2. Click "Add Task" to create a new task
3. Set due date, priority, and recurrence options
4. Check off tasks as you complete them

## Available Scripts

All scripts are in the root directory. Make them executable with: `chmod +x *.sh`

- **install.sh** - Initial installation and setup
- **health-check.sh** - Check status of all services
- **backup.sh** - Create timestamped backup of database
- **restore.sh** - Restore database from backup
- **update.sh** - Update application (with automatic backup)
- **logs.sh** - Interactive log viewer
- **maintenance.sh** - Automated maintenance tasks
- **dev-setup.sh** - Set up development environment
- **reset.sh** - Complete reset (WARNING: deletes all data)

## Docker Commands

```bash
# View logs
docker-compose logs -f

# Stop the application
docker-compose down

# Restart services
docker-compose restart

# Update and rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Environment Variables

Create a `.env` file based on `.env.example` to customize:

```env
# Backend
NODE_ENV=production
MONGO_URI=mongodb://mongodb:27017/consumable-tracker
PORT=5000

# Frontend
REACT_APP_API_URL=http://localhost:5000/api
```

## Backup and Restore

### Backup MongoDB
```bash
docker-compose exec mongodb mongodump --db consumable-tracker --archive=/backup.gz --gzip
docker cp consumable-mongo:/backup.gz ./backup.gz
```

### Restore MongoDB
```bash
docker cp ./backup.gz consumable-mongo:/backup.gz
docker-compose exec mongodb mongorestore --db consumable-tracker --archive=/backup.gz --gzip
```

## Troubleshooting

### Services not starting
- Check port availability: `netstat -tuln | grep -E '3000|5000|27017'`
- View logs: `docker-compose logs -f`

### Cannot connect to backend
- Ensure backend is running: `docker-compose ps`
- Check backend health: `curl http://localhost:5000/health`

### Database connection issues
- Check MongoDB status: `docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"`
- Restart MongoDB: `docker-compose restart mongodb`

## Future Features

- [ ] Collapsible category sidebar
- [ ] Email/Telegram alerts via n8n integration
- [ ] "All items" shopping view
- [ ] Voice assistant integration (Alexa/ChatGPT)
- [ ] Data export/import functionality
- [ ] Multi-user support
- [ ] Mobile app

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.
