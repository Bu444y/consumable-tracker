import React from 'react';
import { Calendar, RefreshCw, Edit2, Trash } from 'lucide-react';

function TaskItem({ task, onToggle, onEdit, onDelete, showCategory = false }) {
  const dueDate = new Date(task.dueDate).toLocaleDateString();
  const isOverdue = new Date(task.dueDate) < new Date() && !task.completed;
  
  return (
    <li className="p-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
      <div className="flex items-start">
        <div className="mr-3 pt-1">
          <input 
            type="checkbox" 
            className="h-5 w-5 rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
            checked={task.completed}
            onChange={onToggle}
          />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between">
            <div>
              <p className={`text-sm font-medium ${
                task.completed ? 'text-gray-400 line-through' : 'text-gray-900 dark:text-gray-100'
              }`}>
                {task.title}
              </p>
              {showCategory && task.category && (
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {task.category.name}
                </p>
              )}
            </div>
            <div className="flex items-center ml-2">
              <span className={`px-2 py-1 text-xs rounded-full ${
                task.priority === 'high' ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300' : 
                task.priority === 'medium' ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300' : 
                'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
              }`}>
                {task.priority}
              </span>
            </div>
          </div>
          {task.description && (
            <p className="text-sm text-gray-500 mt-1">{task.description}</p>
          )}
          <div className="flex items-center mt-1">
            <span className={`text-xs flex items-center ${
              isOverdue ? 'text-red-500' : 'text-gray-500'
            }`}>
              <Calendar size={12} className="mr-1" />
              {isOverdue ? 'Overdue: ' : 'Due '}{dueDate}
            </span>
            {task.recurring?.enabled && (
              <span className="text-xs text-gray-500 ml-3 flex items-center">
                <RefreshCw size={12} className="mr-1" />
                Repeats {task.recurring.frequency}
              </span>
            )}
          </div>
        </div>
        <div className="ml-2 flex">
          <button 
            className="p-1 text-gray-400 hover:text-blue-600"
            onClick={onEdit}
            title="Edit"
          >
            <Edit2 size={16} />
          </button>
          <button 
            className="p-1 text-gray-400 hover:text-red-600 ml-1"
            onClick={onDelete}
            title="Delete"
          >
            <Trash size={16} />
          </button>
        </div>
      </div>
    </li>
  );
}

export default TaskItem;
