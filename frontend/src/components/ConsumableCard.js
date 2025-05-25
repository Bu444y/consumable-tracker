import React from 'react';
import { MinusCircle, RefreshCw, Edit2, Trash } from 'lucide-react';

function ConsumableCard({ consumable, onEdit, onDelete, onDecrease, onRefill, viewMode = 'grid' }) {
  const getStockLevelColor = () => {
    if (consumable.isLowStock) return 'text-red-500 bg-red-50';
    if (consumable.quantity < consumable.alertThreshold * 2) return 'text-yellow-500 bg-yellow-50';
    return 'text-green-500 bg-green-50';
  };

  const formatUnit = (quantity, unit) => {
    if (unit === 'percent') return `${quantity}%`;
    return `${quantity} ${unit}`;
  };

  const emptyDate = consumable.emptyDate ? new Date(consumable.emptyDate).toLocaleDateString() : 'N/A';

  if (viewMode === 'list') {
    return (
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 flex items-center justify-between">
        <div className="flex items-center flex-1">
          {consumable.image && (
            <img src={consumable.image} alt={consumable.name} className="w-12 h-12 rounded mr-4" />
          )}
          <div>
            <h3 className="font-medium text-gray-900 dark:text-gray-100">{consumable.name}</h3>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              {formatUnit(consumable.quantity, consumable.unit)} remaining
              {consumable.decreaseRate > 0 && ` • ${consumable.decreaseRate} per ${consumable.decreaseInterval}`}
            </p>
          </div>
        </div>
        <div className="flex items-center space-x-4">
          <span className={`px-3 py-1 rounded-full text-sm ${getStockLevelColor()}`}>
            {consumable.isLowStock ? 'Low Stock' : 'In Stock'}
          </span>
          {consumable.emptyDate && (
            <span className="text-sm text-gray-500 dark:text-gray-400">
              Empty by {emptyDate}
            </span>
          )}
          <div className="flex space-x-2">
            <button 
              onClick={onDecrease}
              className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
              title="Decrease by 1"
            >
              <MinusCircle size={18} />
            </button>
            <button 
              onClick={onEdit}
              className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors"
            >
              <Edit2 size={18} />
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Grid view (default)
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden fade-in">
      <div className="p-4">
        <div className="flex items-start mb-2">
          {consumable.image && (
            <img src={consumable.image} alt={consumable.name} className="w-12 h-12 rounded mr-3" />
          )}
          <div className="flex-1">
            <h3 className="font-medium text-gray-900 dark:text-gray-100">{consumable.name}</h3>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              {consumable.decreaseRate > 0 
                ? `Using ${consumable.decreaseRate} ${consumable.unit} per ${consumable.decreaseInterval}`
                : 'Manual tracking'}
            </p>
          </div>
        </div>
        
        <div className="mt-3">
          <div className="flex justify-between text-sm mb-1">
            <span className={`font-medium ${consumable.isLowStock ? 'text-red-600' : 'text-gray-700 dark:text-gray-300'}`}>
              {formatUnit(consumable.quantity, consumable.unit)} remaining
            </span>
            {consumable.decreaseRate > 0 && consumable.emptyDate && (
              <span className="text-gray-500 dark:text-gray-400">Empty by {emptyDate}</span>
            )}
          </div>
          
          {consumable.unit === 'percent' && (
            <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
              <div 
                className={`h-2.5 rounded-full transition-all ${
                  consumable.quantity > 60 ? 'bg-green-500' :
                  consumable.quantity > 30 ? 'bg-yellow-500' : 'bg-red-500'
                }`}
                style={{ width: `${consumable.quantity}%` }}
              ></div>
            </div>
          )}
        </div>
        
        <div className="flex justify-between mt-4">
          <div className="flex space-x-2">
            <button 
              className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition-colors"
              onClick={onDecrease}
              title="Decrease by 1 unit"
            >
              <MinusCircle size={18} />
            </button>
            <button 
              className="p-2 text-gray-500 hover:text-green-600 hover:bg-green-50 dark:hover:bg-green-900/20 rounded transition-colors"
              onClick={onRefill}
              title="Refill"
            >
              <RefreshCw size={18} />
            </button>
          </div>
          <div className="flex space-x-2">
            <button 
              className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded transition-colors"
              onClick={onEdit}
              title="Edit"
            >
              <Edit2 size={18} />
            </button>
            <button 
              className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition-colors"
              onClick={onDelete}
              title="Delete"
            >
              <Trash size={18} />
            </button>
          </div>
        </div>
        
        {consumable.notes && (
          <div className="mt-3 pt-3 border-t border-gray-100 dark:border-gray-700">
            <p className="text-xs text-gray-500 dark:text-gray-400">{consumable.notes}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default ConsumableCard;
