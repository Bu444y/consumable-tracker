#!/bin/bash

# Test script to verify API is working and add sample data
# Run this after installation to test the system

set -e

echo "Testing Consumable Tracker API..."
echo "================================="

API_URL="http://localhost:5000/api"

# Test health endpoint
echo -n "Testing health endpoint... "
if curl -f -s http://localhost:5000/health | grep -q "healthy"; then
    echo "✓ OK"
else
    echo "✗ Failed"
    exit 1
fi

# Get existing categories
echo -n "Fetching categories... "
CATEGORIES=$(curl -s $API_URL/categories)
echo "✓ OK"

# Check if we have any consumable categories
KITCHEN_ID=$(echo $CATEGORIES | grep -o '"_id":"[^"]*","name":"Kitchen"' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$KITCHEN_ID" ]; then
    echo "No Kitchen category found. The initial data setup may have failed."
    echo "Creating a test category..."
    
    RESPONSE=$(curl -s -X POST $API_URL/categories \
        -H "Content-Type: application/json" \
        -d '{
            "name": "Test Kitchen",
            "type": "consumable",
            "icon": "kitchen",
            "color": "#4CAF50"
        }')
    
    KITCHEN_ID=$(echo $RESPONSE | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    echo "Created category with ID: $KITCHEN_ID"
fi

# Add a test consumable
echo "Adding a test consumable..."
RESPONSE=$(curl -s -X POST $API_URL/consumables \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Test Item - Dish Soap\",
        \"category\": \"$KITCHEN_ID\",
        \"initialAmount\": 100,
        \"currentAmount\": 75,
        \"decreaseRate\": 2,
        \"decreaseInterval\": \"day\",
        \"alertThreshold\": 20,
        \"notes\": \"This is a test item\"
    }")

if echo $RESPONSE | grep -q '"name":"Test Item - Dish Soap"'; then
    echo "✓ Successfully created test consumable"
else
    echo "✗ Failed to create consumable"
    echo "Response: $RESPONSE"
fi

# Get all consumables to verify
echo -n "Verifying consumables list... "
CONSUMABLES=$(curl -s $API_URL/consumables)
if echo $CONSUMABLES | grep -q "Test Item"; then
    echo "✓ Test item appears in list"
else
    echo "✗ Test item not found in list"
fi

echo ""
echo "API test completed!"
echo "You should now see at least one item in the web interface."
echo "If you still see 'Failed to load data', try:"
echo "1. Clear browser cache (Ctrl+F5)"
echo "2. Check browser console for errors (F12)"
echo "3. Try accessing: http://localhost:3000"
