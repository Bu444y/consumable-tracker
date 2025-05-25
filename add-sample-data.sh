#!/bin/bash

# Add sample data to test the application
# Run this after installation to add test consumables

echo "Adding sample data to Consumable Tracker..."

API_URL="http://localhost:5000/api"

# Get categories
echo "Fetching categories..."
CATEGORIES=$(curl -s $API_URL/categories)

# Extract category IDs
KITCHEN_ID=$(echo $CATEGORIES | grep -o '"_id":"[^"]*","name":"Kitchen"' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4 | head -1)
BATHROOM_ID=$(echo $CATEGORIES | grep -o '"_id":"[^"]*","name":"Bathroom"' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4 | head -1)
CLEANING_ID=$(echo $CATEGORIES | grep -o '"_id":"[^"]*","name":"Cleaning"' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4 | head -1)
HOME_ID=$(echo $CATEGORIES | grep -o '"_id":"[^"]*","name":"Home"' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4 | head -1)

if [ -z "$KITCHEN_ID" ]; then
    echo "Categories not found. Make sure the app is running."
    exit 1
fi

echo "Adding consumables..."

# Kitchen items
curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Rice\",
        \"category\": \"$KITCHEN_ID\",
        \"quantity\": 10,
        \"unit\": \"lbs\",
        \"decreaseRate\": 1,
        \"decreaseInterval\": \"day\",
        \"alertThreshold\": 2,
        \"notes\": \"Jasmine rice\"
    }"

curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Dish Soap\",
        \"category\": \"$KITCHEN_ID\",
        \"quantity\": 32,
        \"unit\": \"oz\",
        \"decreaseRate\": 2,
        \"decreaseInterval\": \"day\",
        \"alertThreshold\": 8,
        \"notes\": \"Dawn dish soap\"
    }"

curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Paper Towels\",
        \"category\": \"$KITCHEN_ID\",
        \"quantity\": 12,
        \"unit\": \"count\",
        \"decreaseRate\": 1,
        \"decreaseInterval\": \"week\",
        \"alertThreshold\": 4,
        \"notes\": \"Bounty rolls\"
    }"

# Bathroom items
curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Toilet Paper\",
        \"category\": \"$BATHROOM_ID\",
        \"quantity\": 24,
        \"unit\": \"count\",
        \"decreaseRate\": 2,
        \"decreaseInterval\": \"week\",
        \"alertThreshold\": 8,
        \"notes\": \"Double rolls\"
    }"

curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Toothpaste\",
        \"category\": \"$BATHROOM_ID\",
        \"quantity\": 3,
        \"unit\": \"count\",
        \"decreaseRate\": 1,
        \"decreaseInterval\": \"month\",
        \"alertThreshold\": 1,
        \"notes\": \"Crest tubes\"
    }"

# Cleaning items
curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Laundry Detergent\",
        \"category\": \"$CLEANING_ID\",
        \"quantity\": 96,
        \"unit\": \"oz\",
        \"decreaseRate\": 12,
        \"decreaseInterval\": \"week\",
        \"alertThreshold\": 24,
        \"notes\": \"Tide liquid\"
    }"

echo ""
echo "Adding tasks..."

# Home tasks
curl -s -X POST $API_URL/tasks \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Clean Kitchen\",
        \"category\": \"$HOME_ID\",
        \"description\": \"Wipe counters, clean sink, sweep floor\",
        \"dueDate\": \"$(date -d '+1 day' --iso-8601)\",
        \"priority\": \"medium\",
        \"recurring\": {
            \"enabled\": true,
            \"frequency\": \"weekly\",
            \"interval\": 1
        }
    }"

curl -s -X POST $API_URL/tasks \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Take Out Trash\",
        \"category\": \"$HOME_ID\",
        \"description\": \"Take bins to curb\",
        \"dueDate\": \"$(date -d '+2 days' --iso-8601)\",
        \"priority\": \"high\",
        \"recurring\": {
            \"enabled\": true,
            \"frequency\": \"weekly\",
            \"interval\": 1
        }
    }"

echo ""
echo "Sample data added successfully!"
echo ""
echo "To test auto-decrease, run:"
echo "  curl -X POST http://localhost:5000/api/consumables/auto-decrease"
echo ""
echo "Check the app at: http://localhost:3000"
