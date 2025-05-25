import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import api from '../services/api';

function TaskModal({ show, onClose, onSave, categories, task, onCategoryAdded }) {
  const [form, setForm] = useState({
    title: '',
    category: '',
    description: '',
    dueDate: new Date().toISOString().split('T')[0],
    priority: 'medium',
    recurring: {
      enabled: false,
      frequency: 'weekly',
      interval: 1,
      days: []
    }
  });
  const [newCategoryName, setNewCategoryName] = useState('');
  const [loading, setLoading] = useState(false);
  const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  useEffect(() => {
    if (task) {
      setForm({
        title: task.title,
        category: task.category._id,
        description: task.description || '',
        dueDate: new Date(task.dueDate).toISOString().split('T')[0],
        priority: task.priority,
        recurring: task.recurring || {
          enabled: false,
          frequency: 'weekly',
          interval: 1,
          days: []
        }
      });
    } else {
      setForm({
        title: '',
        category: categories.length > 0 ? categories[0]._id : '',
        description: '',
        dueDate: new Date().toISOString().split('T')[0],
        priority: 'medium',
        recurring: {
          enabled: false,
          frequency: 'weekly',
          interval: 1,
          days: []
        }
      });
    }
  }, [task, categories]);

  const toggleRecurringDay = (dayIndex) => {
    const days = [...form.recurring.days];
    const index = days.indexOf(dayIndex);
    if (index === -1) {
      days.push(dayIndex);
    } else {
      days.splice(index, 1);
    }
    setForm({
      ...form,
      recurring: { ...form.recurring, days }
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      let categoryId = form.category;

      if (form.category === 'new' && newCategoryName) {
        const response = await api.post('/categories', {
          name: newCategoryName,
          type: 'task',
          icon: 'calendar',
          color: '#' + Math.floor(Math.random()*16777215).toString(16)
        });
        categoryId = response.data._id;
        onCategoryAdded(response.data);
      }

      await onSave({
        ...form,
        category: categoryId,
        dueDate: new Date(form.dueDate)
      });
    } catch (error) {
      console.error('Form submission error:', error);
      alert('Failed to save task. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (!show) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white flex justify-between items-center border-b border-gray-200 p-4">
          <h3 className="text-lg font-semibold">
            {task ? 'Edit Task' : 'Add New Task'}
          </h3>
          <button 
            className="text-gray-400 hover:text-gray-500"
            onClick={onClose}
          >
            <X size={24} />
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-4">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <input 
                type="text" 
                value={form.title}
                onChange={(e) => setForm({...form, title: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                placeholder="Task name"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
              <select 
                value={form.category}
                onChange={(e) => setForm({...form, category: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                required
              >
                {categories.map(category => (
                  <option key={category._id} value={category._id}>
                    {category.name}
                  </option>
                ))}
                <option value="new">+ Add New Category</option>
              </select>
            </div>
            
            {form.category === 'new' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">New Category Name</label>
                <input 
                  type="text" 
                  value={newCategoryName}
                  onChange={(e) => setNewCategoryName(e.target.value)}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Enter new category name"
                  required
                />
              </div>
            )}
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Description (Optional)</label>
              <textarea 
                value={form.description}
                onChange={(e) => setForm({...form, description: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                placeholder="Add any details about this task..."
              />
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Due Date</label>
                <input 
                  type="date" 
                  value={form.dueDate}
                  onChange={(e) => setForm({...form, dueDate: e.target.value})}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
                <select 
                  value={form.priority}
                  onChange={(e) => setForm({...form, priority: e.target.value})}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                  required
                >
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                </select>
              </div>
            </div>
            
            <div className="flex items-center">
              <input 
                type="checkbox" 
                id="recurring-toggle"
                checked={form.recurring.enabled}
                onChange={(e) => setForm({
                  ...form,
                  recurring: { ...form.recurring, enabled: e.target.checked }
                })}
                className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <label htmlFor="recurring-toggle" className="ml-2 block text-sm text-gray-700">
                Recurring Task
              </label>
            </div>
            
            {form.recurring.enabled && (
              <div className="border border-gray-200 rounded-md p-3 bg-gray-50">
                <div className="grid grid-cols-2 gap-4 mb-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Frequency</label>
                    <select 
                      value={form.recurring.frequency}
                      onChange={(e) => setForm({
                        ...form,
                        recurring: { ...form.recurring, frequency: e.target.value }
                      })}
                      className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="daily">Daily</option>
                      <option value="weekly">Weekly</option>
                      <option value="monthly">Monthly</option>
                      <option value="custom">Custom</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Interval</label>
                    <input 
                      type="number" 
                      value={form.recurring.interval}
                      onChange={(e) => setForm({
                        ...form,
                        recurring: { ...form.recurring, interval: parseInt(e.target.value) }
                      })}
                      className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                      min="1"
                      max={form.recurring.frequency === 'daily' ? 14 : 12}
                    />
                  </div>
                </div>
                
                {form.recurring.frequency === 'custom' && (
                  <div className="mt-3">
                    <label className="block text-sm font-medium text-gray-700 mb-2">Days of Week</label>
                    <div className="flex flex-wrap gap-2">
                      {daysOfWeek.map((day, index) => (
                        <button 
                          key={day}
                          type="button"
                          onClick={() => toggleRecurringDay(index)}
                          className={`px-3 py-1 rounded-full text-xs ${
                            form.recurring.days.includes(index) 
                              ? 'bg-blue-600 text-white' 
                              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                          }`}
                        >
                          {day}
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
          
          <div className="mt-6 flex justify-end space-x-3">
            <button 
              type="button"
              className="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md"
              onClick={onClose}
            >
              Cancel
            </button>
            <button 
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white hover:bg-blue-700 rounded-md"
              disabled={loading}
            >
              {loading ? 'Saving...' : (task ? 'Update' : 'Save')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default TaskModal;
