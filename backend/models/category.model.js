const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  icon: {
    type: String,
    default: 'box'
  },
  type: {
    type: String,
    enum: ['consumable', 'task'],
    required: true
  },
  color: {
    type: String,
    default: '#3498db'
  },
  order: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Category', categorySchema);
