const express = require('express');
const router = express.Router();
const Task = require('../models/task.model');

// Get all tasks
router.get('/', async (req, res) => {
  try {
    const tasks = await Task.find().populate('category').sort('dueDate');
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get tasks by category
router.get('/category/:categoryId', async (req, res) => {
  try {
    const tasks = await Task.find({ category: req.params.categoryId })
      .populate('category')
      .sort('dueDate');
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get tasks by status
router.get('/status/:status', async (req, res) => {
  const completed = req.params.status === 'completed';
  
  try {
    const tasks = await Task.find({ completed })
      .populate('category')
      .sort('dueDate');
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get specific task
router.get('/:id', async (req, res) => {
  try {
    const task = await Task.findById(req.params.id).populate('category');
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create a new task
router.post('/', async (req, res) => {
  const task = new Task(req.body);
  
  try {
    const newTask = await task.save();
    const populatedTask = await Task.findById(newTask._id).populate('category');
    res.status(201).json(populatedTask);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update task
router.put('/:id', async (req, res) => {
  try {
    const task = await Task.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('category');
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json(task);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete task
router.delete('/:id', async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json({ message: 'Task deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Toggle task completion
router.post('/:id/toggle', async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    
    if (!task) return res.status(404).json({ message: 'Task not found' });
    
    if (task.recurring.enabled) {
      // For recurring tasks, just update the due date to next occurrence
      task.dueDate = calculateNextDueDate(task.dueDate, task.recurring);
      task.completed = false; // Always reset to incomplete for next occurrence
      task.completedOn = new Date(); // Track when it was last done
    } else {
      // For non-recurring tasks, toggle completion normally
      task.completed = !task.completed;
      task.completedOn = task.completed ? new Date() : null;
    }
    
    await task.save();
    const updatedTask = await Task.findById(task._id).populate('category');
    res.json(updatedTask);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Helper function to calculate next due date
function calculateNextDueDate(currentDue, recurring) {
  const nextDate = new Date(currentDue);
  
  switch (recurring.frequency) {
    case 'daily':
      nextDate.setDate(nextDate.getDate() + recurring.interval);
      break;
    case 'weekly':
      nextDate.setDate(nextDate.getDate() + (7 * recurring.interval));
      break;
    case 'monthly':
      nextDate.setMonth(nextDate.getMonth() + recurring.interval);
      break;
    case 'custom':
      // Find next valid day
      const currentDay = nextDate.getDay();
      let daysToAdd = 7;
      for (let i = 1; i <= 7; i++) {
        const checkDay = (currentDay + i) % 7;
        if (recurring.days.includes(checkDay)) {
          daysToAdd = i;
          break;
        }
      }
      nextDate.setDate(nextDate.getDate() + daysToAdd);
      break;
  }
  
  return nextDate;
}

module.exports = router;
