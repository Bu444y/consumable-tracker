# Consumable Tracker API Documentation

Base URL: `http://localhost:5000/api`

## Endpoints

### Categories

#### Get all categories
```
GET /categories
```

#### Get categories by type
```
GET /categories/type/:type
```
Parameters:
- `type`: 'consumable' or 'task'

#### Create category
```
POST /categories
Content-Type: application/json

{
  "name": "Office Supplies",
  "type": "consumable",
  "icon": "box",
  "color": "#FF5733"
}
```

### Consumables

#### Get all consumables
```
GET /consumables
```

#### Get consumables by category
```
GET /consumables/category/:categoryId
```

#### Create consumable
```
POST /consumables
Content-Type: application/json

{
  "name": "Printer Paper",
  "category": "category_id",
  "initialAmount": 100,
  "currentAmount": 100,
  "decreaseRate": 2,
  "decreaseInterval": "week",
  "alertThreshold": 20,
  "notes": "A4 size, 500 sheets per ream"
}
```

#### Update consumable
```
PUT /consumables/:id
Content-Type: application/json

{
  "currentAmount": 75
}
```

#### Decrease amount
```
POST /consumables/:id/decrease
Content-Type: application/json

{
  "amount": 10
}
```

#### Refill consumable
```
POST /consumables/:id/refill
Content-Type: application/json

{
  "amount": 100
}
```

### Tasks

#### Get all tasks
```
GET /tasks
```

#### Get tasks by category
```
GET /tasks/category/:categoryId
```

#### Get tasks by status
```
GET /tasks/status/:status
```
Parameters:
- `status`: 'active' or 'completed'

#### Create task
```
POST /tasks
Content-Type: application/json

{
  "title": "Clean gutters",
  "category": "category_id",
  "description": "Clear leaves and debris",
  "dueDate": "2024-12-25",
  "priority": "high",
  "recurring": {
    "enabled": true,
    "frequency": "monthly",
    "interval": 3
  }
}
```

#### Toggle task completion
```
POST /tasks/:id/toggle
```

## Integration Examples

### n8n Webhook Example
```javascript
// Low stock alert webhook
{
  "event": "low_stock",
  "item": {
    "name": "Dish Soap",
    "remaining": 15,
    "category": "Kitchen"
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### Voice Assistant Integration
```
"Alexa, ask Consumable Tracker how much dish soap is left"
"Alexa, tell Consumable Tracker to add paper towels to kitchen"
"Alexa, ask Consumable Tracker what tasks are due today"
```

### Example CURL Commands

Get all kitchen consumables:
```bash
curl http://localhost:5000/api/consumables/category/[kitchen_category_id]
```

Decrease dish soap by 5%:
```bash
curl -X POST http://localhost:5000/api/consumables/[item_id]/decrease \
  -H "Content-Type: application/json" \
  -d '{"amount": 5}'
```

Complete a task:
```bash
curl -X POST http://localhost:5000/api/tasks/[task_id]/toggle
```
