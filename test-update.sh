#!/bin/bash

# Post-update test script
# Run this after updating to v1.1.0 to verify everything works

echo "Consumable Tracker v1.1.0 - Post-Update Test"
echo "==========================================="
echo ""

# Check if services are running
echo "1. Checking services..."
if docker-compose ps | grep -q "Up"; then
    echo "✓ Services are running"
    docker-compose ps
else
    echo "✗ Services not running. Run: ./install.sh"
    exit 1
fi

echo ""
echo "2. Testing API endpoints..."

# Test health
echo -n "   Health check: "
if curl -s http://localhost:5000/health | grep -q "healthy"; then
    echo "✓ Healthy"
else
    echo "✗ Failed"
fi

# Test categories
echo -n "   Categories: "
CATS=$(curl -s http://localhost:5000/api/categories)
if echo "$CATS" | grep -q "Kitchen"; then
    echo "✓ Found $(echo "$CATS" | grep -o "_id" | wc -l) categories"
else
    echo "✗ No categories found"
fi

# Test consumables
echo -n "   Consumables: "
ITEMS=$(curl -s http://localhost:5000/api/consumables)
COUNT=$(echo "$ITEMS" | grep -o "_id" | wc -l)
echo "✓ Found $COUNT items"

# Test auto-decrease
echo ""
echo "3. Testing auto-decrease..."
echo -n "   Triggering auto-decrease: "
if curl -s -X POST http://localhost:5000/api/consumables/auto-decrease | grep -q "completed"; then
    echo "✓ Success"
else
    echo "✗ Failed"
fi

echo ""
echo "4. Testing frontend..."
echo -n "   Loading page: "
if curl -s http://localhost:3000 | grep -q "<title>"; then
    echo "✓ Frontend responding"
else
    echo "✗ Frontend not responding"
fi

echo ""
echo "5. Feature checklist:"
echo "   [ ] Dark mode toggle works"
echo "   [ ] Grid/List view toggle works"
echo "   [ ] All Consumables view shows items"
echo "   [ ] All Tasks view shows tasks"
echo "   [ ] Sorting options work"
echo "   [ ] Add new consumable with units"
echo "   [ ] Decrease button reduces by 1 unit"
echo "   [ ] Refill opens modal with quantity"
echo "   [ ] Recurring task reschedules on complete"
echo "   [ ] Low stock indicators show correctly"

echo ""
echo "6. Browser test links:"
IP=$(hostname -I | awk '{print $1}')
echo "   Main app: http://$IP:3000"
echo "   All consumables: http://$IP:3000 (click 'All Consumables')"
echo "   API test: http://$IP:5000/api/categories"

echo ""
echo "7. Quick actions:"
echo "   Add sample data: ./add-sample-data.sh"
echo "   View logs: ./logs.sh"
echo "   Force decrease: curl -X POST http://localhost:5000/api/consumables/auto-decrease"

echo ""
echo "============================================"
echo "If all tests pass, v1.1.0 is working correctly!"
echo "Report issues at: https://github.com/Bu444y/consumable-tracker/issues"
