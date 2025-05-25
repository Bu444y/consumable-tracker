const mongoose = require('mongoose');

const consumableSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  quantity: {
    type: Number,
    default: 100,
    required: true
  },
  unit: {
    type: String,
    enum: ['count', 'lbs', 'oz', 'kg', 'g', 'ml', 'l', 'percent'],
    default: 'count'
  },
  decreaseRate: {
    type: Number,
    default: 0
  },
  decreaseInterval: {
    type: String,
    enum: ['day', 'week', 'month'],
    default: 'day'
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  lastAutoDecreased: {
    type: Date,
    default: Date.now
  },
  image: {
    type: String
  },
  alertThreshold: {
    type: Number,
    default: 20
  },
  notes: {
    type: String
  },
  isCollapsed: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Virtual field for empty date calculation
consumableSchema.virtual('emptyDate').get(function() {
  if (this.decreaseRate === 0 || this.quantity <= 0) return null;
  
  // Calculate days until empty based on actual units
  const unitsPerDay = this.decreaseRate / (this.decreaseInterval === 'week' ? 7 : this.decreaseInterval === 'month' ? 30 : 1);
  const daysUntilEmpty = this.quantity / unitsPerDay;
  
  const emptyDate = new Date();
  emptyDate.setDate(emptyDate.getDate() + Math.floor(daysUntilEmpty));
  
  return emptyDate.toISOString().split('T')[0];
});

// Virtual field to check if low stock
consumableSchema.virtual('isLowStock').get(function() {
  return this.quantity <= this.alertThreshold;
});

// Method to decrease quantity
consumableSchema.methods.decrease = function(amount = 1) {
  this.quantity = Math.max(0, this.quantity - amount);
  this.lastUpdated = new Date();
  return this.save();
};

// Method to refill
consumableSchema.methods.refill = function(amount) {
  this.quantity = amount;
  this.lastUpdated = new Date();
  return this.save();
};

// Static method to auto-decrease all items
consumableSchema.statics.autoDecreaseAll = async function() {
  const now = new Date();
  const consumables = await this.find({ decreaseRate: { $gt: 0 } });
  
  for (const item of consumables) {
    const lastDecreased = item.lastAutoDecreased || item.createdAt;
    const timeDiff = now - lastDecreased;
    const daysDiff = timeDiff / (1000 * 60 * 60 * 24);
    
    let intervalDays = 1;
    if (item.decreaseInterval === 'week') intervalDays = 7;
    if (item.decreaseInterval === 'month') intervalDays = 30;
    
    const periodsElapsed = Math.floor(daysDiff / intervalDays);
    
    if (periodsElapsed > 0) {
      const decreaseAmount = item.decreaseRate * periodsElapsed;
      item.quantity = Math.max(0, item.quantity - decreaseAmount);
      item.lastAutoDecreased = now;
      await item.save();
      console.log(`Auto-decreased ${item.name} by ${decreaseAmount} ${item.unit}`);
    }
  }
};

// Include virtuals when converting to JSON
consumableSchema.set('toJSON', { virtuals: true });
consumableSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Consumable', consumableSchema);
