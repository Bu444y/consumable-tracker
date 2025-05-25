#!/bin/bash

# Log viewer script for Consumable Tracker
# Provides easy access to service logs

echo "Consumable Tracker Logs"
echo "======================="
echo ""
echo "Select which logs to view:"
echo "1) All services"
echo "2) Frontend only"
echo "3) Backend only"
echo "4) MongoDB only"
echo "5) Last 100 lines of all services"
echo "q) Quit"
echo ""

read -p "Enter your choice: " choice

case $choice in
    1)
        echo "Showing all service logs (Ctrl+C to exit)..."
        docker-compose logs -f
        ;;
    2)
        echo "Showing frontend logs (Ctrl+C to exit)..."
        docker-compose logs -f frontend
        ;;
    3)
        echo "Showing backend logs (Ctrl+C to exit)..."
        docker-compose logs -f backend
        ;;
    4)
        echo "Showing MongoDB logs (Ctrl+C to exit)..."
        docker-compose logs -f mongodb
        ;;
    5)
        echo "Last 100 lines of all services:"
        docker-compose logs --tail=100
        ;;
    q|Q)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
