const express = require('express');
const router = express.Router();
const Consumable = require('../models/consumable.model');

// Get all consumables
router.get('/', async (req, res) => {
  try {
    const consumables = await Consumable.find().populate('category');
    res.json(consumables);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get consumables by category
router.get('/category/:categoryId', async (req, res) => {
  try {
    const consumables = await Consumable.find({ category: req.params.categoryId }).populate('category');
    res.json(consumables);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get specific consumable
router.get('/:id', async (req, res) => {
  try {
    const consumable = await Consumable.findById(req.params.id).populate('category');
    if (!consumable) return res.status(404).json({ message: 'Consumable not found' });
    res.json(consumable);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create new consumable
router.post('/', async (req, res) => {
  const consumable = new Consumable(req.body);
  
  try {
    const newConsumable = await consumable.save();
    const populatedConsumable = await Consumable.findById(newConsumable._id).populate('category');
    res.status(201).json(populatedConsumable);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update consumable
router.put('/:id', async (req, res) => {
  try {
    const consumable = await Consumable.findByIdAndUpdate(
      req.params.id, 
      { ...req.body, lastUpdated: Date.now() }, 
      { new: true }
    ).populate('category');
    if (!consumable) return res.status(404).json({ message: 'Consumable not found' });
    res.json(consumable);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete consumable
router.delete('/:id', async (req, res) => {
  try {
    const consumable = await Consumable.findByIdAndDelete(req.params.id);
    if (!consumable) return res.status(404).json({ message: 'Consumable not found' });
    res.json({ message: 'Consumable deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Decrease amount
router.post('/:id/decrease', async (req, res) => {
  try {
    const { amount = 1 } = req.body; // Default to 1 unit
    const consumable = await Consumable.findById(req.params.id);
    
    if (!consumable) return res.status(404).json({ message: 'Consumable not found' });
    
    await consumable.decrease(amount);
    const updatedConsumable = await Consumable.findById(consumable._id).populate('category');
    res.json(updatedConsumable);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Refill amount
router.post('/:id/refill', async (req, res) => {
  try {
    const { amount } = req.body;
    const consumable = await Consumable.findById(req.params.id);
    
    if (!consumable) return res.status(404).json({ message: 'Consumable not found' });
    if (!amount || amount <= 0) return res.status(400).json({ message: 'Invalid refill amount' });
    
    await consumable.refill(amount);
    const updatedConsumable = await Consumable.findById(consumable._id).populate('category');
    res.json(updatedConsumable);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Force auto-decrease (for testing)
router.post('/auto-decrease', async (req, res) => {
  try {
    await Consumable.autoDecreaseAll();
    res.json({ message: 'Auto-decrease completed' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
