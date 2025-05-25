const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');

// Create Express app
const app = express();

// Middleware
app.use(cors({
  origin: function(origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // Allow any localhost origin
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
      return callback(null, true);
    }
    
    // In production, you might want to whitelist specific domains
    return callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(morgan('dev'));

// Connect to MongoDB with retry logic
const connectDB = async () => {
  const maxRetries = 10;
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      await mongoose.connect(process.env.MONGO_URI || 'mongodb://mongodb:27017/consumable-tracker', {
        useNewUrlParser: true,
        useUnifiedTopology: true
      });
      console.log('MongoDB connected successfully');
      break;
    } catch (err) {
      retries++;
      console.error(`MongoDB connection attempt ${retries} failed:`, err.message);
      if (retries < maxRetries) {
        console.log(`Retrying in 5 seconds...`);
        await new Promise(resolve => setTimeout(resolve, 5000));
      } else {
        console.error('Max retries reached. Exiting...');
        process.exit(1);
      }
    }
  }
};

connectDB();

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to Consumable Tracker API',
    endpoints: {
      categories: '/api/categories',
      consumables: '/api/consumables',
      tasks: '/api/tasks'
    }
  });
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await mongoose.connection.db.admin().ping();
    res.json({ 
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(503).json({ 
      status: 'unhealthy',
      database: 'disconnected',
      error: err.message
    });
  }
});

// API Routes
app.use('/api/categories', require('./routes/category.routes'));
app.use('/api/consumables', require('./routes/consumable.routes'));
app.use('/api/tasks', require('./routes/task.routes'));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    message: 'Something went wrong!',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

// Add initial data if database is empty
const setupInitialData = async () => {
  try {
    const Category = require('./models/category.model');
    const categoryCount = await Category.countDocuments();
    
    if (categoryCount === 0) {
      console.log('Setting up initial categories...');
      
      const categories = [
        { name: 'Kitchen', icon: 'kitchen', type: 'consumable', color: '#4CAF50', order: 1 },
        { name: 'Bathroom', icon: 'bathroom', type: 'consumable', color: '#2196F3', order: 2 },
        { name: 'Cleaning', icon: 'cleaning', type: 'consumable', color: '#9C27B0', order: 3 },
        { name: 'Home', icon: 'home', type: 'task', color: '#FF9800', order: 1 },
        { name: 'Yard', icon: 'yard', type: 'task', color: '#4CAF50', order: 2 },
        { name: 'Maintenance', icon: 'build', type: 'task', color: '#607D8B', order: 3 }
      ];
      
      await Category.insertMany(categories);
      console.log('Initial categories created');
    }
  } catch (error) {
    console.error('Error setting up initial data:', error);
  }
};

// Set up initial data once connected
mongoose.connection.once('open', () => {
  setupInitialData();
  
  // Run auto-decrease every hour
  setInterval(async () => {
    try {
      const Consumable = require('./models/consumable.model');
      await Consumable.autoDecreaseAll();
      console.log('Auto-decrease completed at', new Date().toISOString());
    } catch (error) {
      console.error('Auto-decrease error:', error);
    }
  }, 60 * 60 * 1000); // Every hour
  
  // Run once on startup after a delay
  setTimeout(async () => {
    try {
      const Consumable = require('./models/consumable.model');
      await Consumable.autoDecreaseAll();
      console.log('Initial auto-decrease completed');
    } catch (error) {
      console.error('Initial auto-decrease error:', error);
    }
  }, 5000); // 5 seconds after startup
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  await mongoose.connection.close();
  process.exit(0);
});
