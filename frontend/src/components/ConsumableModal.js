import React, { useState, useEffect } from 'react';
import { X, Upload } from 'lucide-react';
import api from '../services/api';

function ConsumableModal({ show, onClose, onSave, categories, consumable, onCategoryAdded }) {
  const [form, setForm] = useState({
    name: '',
    category: '',
    quantity: 100,
    unit: 'count',
    decreaseRate: 1,
    decreaseInterval: 'day',
    alertThreshold: 20,
    notes: '',
    image: ''
  });
  const [newCategoryName, setNewCategoryName] = useState('');
  const [loading, setLoading] = useState(false);
  const [showRefillAmount, setShowRefillAmount] = useState(false);
  const [refillAmount, setRefillAmount] = useState(100);

  const units = [
    { value: 'count', label: 'Count' },
    { value: 'lbs', label: 'Pounds (lbs)' },
    { value: 'oz', label: 'Ounces (oz)' },
    { value: 'kg', label: 'Kilograms (kg)' },
    { value: 'g', label: 'Grams (g)' },
    { value: 'l', label: 'Liters (l)' },
    { value: 'ml', label: 'Milliliters (ml)' },
    { value: 'percent', label: 'Percent (%)' }
  ];

  useEffect(() => {
    if (consumable) {
      setForm({
        name: consumable.name,
        category: consumable.category._id,
        quantity: consumable.quantity,
        unit: consumable.unit || 'count',
        decreaseRate: consumable.decreaseRate,
        decreaseInterval: consumable.decreaseInterval,
        alertThreshold: consumable.alertThreshold,
        notes: consumable.notes || '',
        image: consumable.image || ''
      });
      setShowRefillAmount(true);
      setRefillAmount(consumable.quantity);
    } else {
      setForm({
        name: '',
        category: categories.length > 0 ? categories[0]._id : '',
        quantity: 100,
        unit: 'count',
        decreaseRate: 1,
        decreaseInterval: 'day',
        alertThreshold: 20,
        notes: '',
        image: ''
      });
      setShowRefillAmount(false);
    }
  }, [consumable, categories]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      let categoryId = form.category;

      if (form.category === 'new' && newCategoryName) {
        const response = await api.post('/categories', {
          name: newCategoryName,
          type: 'consumable',
          icon: 'box',
          color: '#' + Math.floor(Math.random()*16777215).toString(16)
        });
        categoryId = response.data._id;
        onCategoryAdded(response.data);
      }

      await onSave({ ...form, category: categoryId });
    } catch (error) {
      console.error('Form submission error:', error);
      alert('Failed to save. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleRefill = async () => {
    if (!consumable) return;
    
    try {
      setLoading(true);
      await api.post(`/consumables/${consumable._id}/refill`, { amount: refillAmount });
      onClose();
      window.location.reload(); // Quick fix - should update state properly
    } catch (error) {
      console.error('Refill error:', error);
      alert('Failed to refill');
    } finally {
      setLoading(false);
    }
  };

  if (!show) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white dark:bg-gray-800 flex justify-between items-center border-b border-gray-200 dark:border-gray-700 p-4">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
            {consumable ? 'Edit Consumable' : 'Add New Consumable'}
          </h3>
          <button 
            className="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300"
            onClick={onClose}
          >
            <X size={24} />
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-4">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
              <input 
                type="text" 
                value={form.name}
                onChange={(e) => setForm({...form, name: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                placeholder="Product name"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category</label>
              <select 
                value={form.category}
                onChange={(e) => setForm({...form, category: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
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
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">New Category Name</label>
                <input 
                  type="text" 
                  value={newCategoryName}
                  onChange={(e) => setNewCategoryName(e.target.value)}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                  placeholder="Enter new category name"
                  required
                />
              </div>
            )}
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {consumable && showRefillAmount ? 'Refill to' : 'Initial Quantity'}
                </label>
                <input 
                  type="number" 
                  value={consumable && showRefillAmount ? refillAmount : form.quantity}
                  onChange={(e) => {
                    const val = parseFloat(e.target.value) || 0;
                    if (consumable && showRefillAmount) {
                      setRefillAmount(val);
                    } else {
                      setForm({...form, quantity: val});
                    }
                  }}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                  min="0"
                  step="any"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                <select 
                  value={form.unit}
                  onChange={(e) => setForm({...form, unit: e.target.value})}
                  className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                  required
                >
                  {units.map(unit => (
                    <option key={unit.value} value={unit.value}>
                      {unit.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            
            {!consumable && (
              <>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Decrease Rate</label>
                    <input 
                      type="number" 
                      value={form.decreaseRate}
                      onChange={(e) => setForm({...form, decreaseRate: parseFloat(e.target.value) || 0})}
                      className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                      min="0"
                      step="0.1"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Interval</label>
                    <select 
                      value={form.decreaseInterval}
                      onChange={(e) => setForm({...form, decreaseInterval: e.target.value})}
                      className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                      required
                    >
                      <option value="day">Per Day</option>
                      <option value="week">Per Week</option>
                      <option value="month">Per Month</option>
                    </select>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Alert Threshold ({form.unit === 'percent' ? '%' : form.unit})
                  </label>
                  <input 
                    type="number" 
                    value={form.alertThreshold}
                    onChange={(e) => setForm({...form, alertThreshold: parseFloat(e.target.value) || 0})}
                    className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                    min="0"
                    step="any"
                    required
                  />
                </div>
              </>
            )}
            
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Image URL (Optional)</label>
              <div className="flex items-center space-x-2">
                <input 
                  type="text" 
                  value={form.image}
                  onChange={(e) => setForm({...form, image: e.target.value})}
                  className="flex-1 px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100"
                  placeholder="https://example.com/image.jpg"
                />
                <button
                  type="button"
                  className="p-2 border rounded-md hover:bg-gray-50 dark:hover:bg-gray-700"
                  title="Upload image"
                >
                  <Upload size={20} />
                </button>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes (Optional)</label>
              <textarea 
                value={form.notes}
                onChange={(e) => setForm({...form, notes: e.target.value})}
                className="w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-100 h-20"
                placeholder="Add any additional details..."
              />
            </div>
          </div>
          
          <div className="mt-6 flex justify-end space-x-3">
            <button 
              type="button"
              className="px-4 py-2 text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-md"
              onClick={onClose}
            >
              Cancel
            </button>
            {consumable && showRefillAmount ? (
              <button 
                type="button"
                className="px-4 py-2 bg-green-600 text-white hover:bg-green-700 rounded-md"
                onClick={handleRefill}
                disabled={loading}
              >
                {loading ? 'Refilling...' : 'Refill'}
              </button>
            ) : (
              <button 
                type="submit"
                className="px-4 py-2 bg-blue-600 text-white hover:bg-blue-700 rounded-md"
                disabled={loading}
              >
                {loading ? 'Saving...' : (consumable ? 'Update' : 'Save')}
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}

export default ConsumableModal;
