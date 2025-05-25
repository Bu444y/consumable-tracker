import React, { useState, useEffect } from 'react';
import { 
  Home, 
  ShoppingBag, 
  List, 
  Settings, 
  Plus, 
  Edit2, 
  Trash, 
  MinusCircle, 
  RefreshCw,
  Calendar,
  Bell,
  User,
  AlertCircle,
  CheckCircle,
  X,
  ArrowLeft,
  Grid,
  Menu,
  Package,
  Sun,
  Moon,
  SortAsc,
  SortDesc,
  Filter
} from 'lucide-react';
import api from './services/api';
import ConsumableModal from './components/ConsumableModal';
import TaskModal from './components/TaskModal';
import ConsumableCard from './components/ConsumableCard';
import TaskItem from './components/TaskItem';
import LoadingSpinner from './components/LoadingSpinner';
import ErrorMessage from './components/ErrorMessage';

function App() {
  const [activeTab, setActiveTab] = useState('loading');
  const [categories, setCategories] = useState([]);
  const [consumables, setConsumables] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState('consumable');
  const [editingItem, setEditingItem] = useState(null);
  const [notification, setNotification] = useState(null);
  const [lastNonSettingsTab, setLastNonSettingsTab] = useState(null);
  
  // View and sorting states
  const [viewMode, setViewMode] = useState('grid'); // grid, list
  const [sortBy, setSortBy] = useState('name'); // name, quantity, date, priority
  const [sortOrder, setSortOrder] = useState('asc'); // asc, desc
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [showMobileMenu, setShowMobileMenu] = useState(false);

  // Apply dark mode class to body
  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('darkMode', 'true');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('darkMode', 'false');
    }
  }, [darkMode]);

  // Fetch initial data
  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [categoriesRes, consumablesRes, tasksRes] = await Promise.all([
        api.get('/categories'),
        api.get('/consumables'),
        api.get('/tasks')
      ]);
      
      setCategories(categoriesRes.data);
      setConsumables(consumablesRes.data);
      setTasks(tasksRes.data);
      
      // Set initial tab
      const consumableCats = categoriesRes.data.filter(c => c.type === 'consumable');
      const taskCats = categoriesRes.data.filter(c => c.type === 'task');
      
      if (consumableCats.length > 0) {
        setActiveTab(consumableCats[0]._id);
        setLastNonSettingsTab(consumableCats[0]._id);
      } else if (taskCats.length > 0) {
        setActiveTab(taskCats[0]._id);
        setLastNonSettingsTab(taskCats[0]._id);
      } else {
        setActiveTab('settings');
      }
    } catch (err) {
      setError('Failed to load data. Please check your connection and try again.');
      console.error('Error fetching data:', err);
      setActiveTab('settings');
    } finally {
      setLoading(false);
    }
  };

  const showNotification = (message, type = 'success') => {
    setNotification({ message, type });
    setTimeout(() => setNotification(null), 3000);
  };

  const openAddModal = (type) => {
    setModalType(type);
    setEditingItem(null);
    setShowModal(true);
  };

  const openEditModal = (type, item) => {
    setModalType(type);
    setEditingItem(item);
    setShowModal(true);
  };

  const handleSaveConsumable = async (data) => {
    try {
      if (editingItem) {
        const res = await api.put(`/consumables/${editingItem._id}`, data);
        setConsumables(consumables.map(c => c._id === editingItem._id ? res.data : c));
        showNotification('Consumable updated successfully');
      } else {
        const res = await api.post('/consumables', data);
        setConsumables([...consumables, res.data]);
        showNotification('Consumable added successfully');
      }
      setShowModal(false);
    } catch (err) {
      showNotification('Failed to save consumable', 'error');
      console.error('Save error:', err);
    }
  };

  const handleSaveTask = async (data) => {
    try {
      if (editingItem) {
        const res = await api.put(`/tasks/${editingItem._id}`, data);
        setTasks(tasks.map(t => t._id === editingItem._id ? res.data : t));
        showNotification('Task updated successfully');
      } else {
        const res = await api.post('/tasks', data);
        setTasks([...tasks, res.data]);
        showNotification('Task added successfully');
      }
      setShowModal(false);
    } catch (err) {
      showNotification('Failed to save task', 'error');
      console.error('Save error:', err);
    }
  };

  const handleDeleteConsumable = async (id) => {
    if (!window.confirm('Are you sure you want to delete this item?')) return;
    
    try {
      await api.delete(`/consumables/${id}`);
      setConsumables(consumables.filter(c => c._id !== id));
      showNotification('Consumable deleted successfully');
    } catch (err) {
      showNotification('Failed to delete consumable', 'error');
    }
  };

  const handleDeleteTask = async (id) => {
    if (!window.confirm('Are you sure you want to delete this task?')) return;
    
    try {
      await api.delete(`/tasks/${id}`);
      setTasks(tasks.filter(t => t._id !== id));
      showNotification('Task deleted successfully');
    } catch (err) {
      showNotification('Failed to delete task', 'error');
    }
  };

  const handleDecreaseConsumable = async (id) => {
    try {
      const res = await api.post(`/consumables/${id}/decrease`);
      setConsumables(consumables.map(c => c._id === id ? res.data : c));
    } catch (err) {
      showNotification('Failed to update amount', 'error');
    }
  };

  const handleRefillConsumable = async (id) => {
    const consumable = consumables.find(c => c._id === id);
    if (consumable) {
      openEditModal('consumable', consumable);
    }
  };

  const handleToggleTask = async (id) => {
    try {
      const res = await api.post(`/tasks/${id}/toggle`);
      setTasks(tasks.map(t => t._id === id ? res.data : t));
      const task = tasks.find(t => t._id === id);
      if (task?.recurring?.enabled) {
        showNotification('Task completed and rescheduled');
      }
    } catch (err) {
      showNotification('Failed to update task', 'error');
    }
  };

  const handleCategoryAdded = (newCategory) => {
    setCategories([...categories, newCategory]);
    setActiveTab(newCategory._id);
    setLastNonSettingsTab(newCategory._id);
  };

  const handleTabChange = (tabId) => {
    if (tabId !== 'settings' && tabId !== activeTab) {
      setLastNonSettingsTab(tabId);
    }
    setActiveTab(tabId);
    setShowMobileMenu(false);
  };

  // Sort functions
  const sortConsumables = (items) => {
    const sorted = [...items].sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'quantity':
          return a.quantity - b.quantity;
        case 'emptyDate':
          const dateA = a.emptyDate ? new Date(a.emptyDate) : new Date(9999, 11, 31);
          const dateB = b.emptyDate ? new Date(b.emptyDate) : new Date(9999, 11, 31);
          return dateA - dateB;
        default:
          return 0;
      }
    });
    return sortOrder === 'desc' ? sorted.reverse() : sorted;
  };

  const sortTasks = (items) => {
    const sorted = [...items].sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.title.localeCompare(b.title);
        case 'date':
          return new Date(a.dueDate) - new Date(b.dueDate);
        case 'priority':
          const priorityOrder = { high: 3, medium: 2, low: 1 };
          return priorityOrder[b.priority] - priorityOrder[a.priority];
        default:
          return 0;
      }
    });
    return sortOrder === 'desc' ? sorted.reverse() : sorted;
  };

  // Filter items based on active tab
  const activeCategory = categories.find(c => c._id === activeTab);
  const isTaskCategory = activeCategory?.type === 'task';
  const isConsumableCategory = activeCategory?.type === 'consumable';
  
  let filteredConsumables = activeTab === 'all-consumables' 
    ? consumables 
    : consumables.filter(item => item.category && item.category._id === activeTab);
  
  let filteredTasks = activeTab === 'all-tasks'
    ? tasks
    : tasks.filter(item => item.category && item.category._id === activeTab);

  // Apply sorting
  filteredConsumables = sortConsumables(filteredConsumables);
  filteredTasks = sortTasks(filteredTasks);

  // Sidebar categories
  const sidebarCategories = [
    { _id: 'all-consumables', name: 'All Consumables', icon: 'package', type: 'all-consumables' },
    ...categories.filter(c => c.type === 'consumable'),
    { _id: 'divider-1', type: 'divider' },
    { _id: 'all-tasks', name: 'All Tasks', icon: 'list', type: 'all-tasks' },
    ...categories.filter(c => c.type === 'task'),
    { _id: 'divider-2', type: 'divider' },
    { _id: 'settings', name: 'Settings', icon: 'settings', type: 'settings' }
  ];

  const getIcon = (iconName) => {
    const icons = {
      home: <Home size={20} />,
      kitchen: <Home size={20} />,
      bathroom: <ShoppingBag size={20} />,
      cleaning: <ShoppingBag size={20} />,
      yard: <List size={20} />,
      build: <List size={20} />,
      settings: <Settings size={20} />,
      package: <Package size={20} />,
      list: <List size={20} />
    };
    return icons[iconName] || <Home size={20} />;
  };

  const handleForceAutoDecrease = async () => {
    try {
      await api.post('/consumables/auto-decrease');
      showNotification('Auto-decrease completed');
      fetchData(); // Reload data
    } catch (err) {
      showNotification('Failed to run auto-decrease', 'error');
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen />;
  }

  return (
    <div className="flex h-screen bg-gray-100 dark:bg-gray-900">
      {/* Add dark mode styles */}
      <style>{`
        .dark {
          color-scheme: dark;
        }
        .dark input, .dark select, .dark textarea {
          color-scheme: dark;
        }
      `}</style>

      {/* Notification */}
      {notification && (
        <div className={`fixed top-4 right-4 z-50 flex items-center p-4 rounded-lg shadow-lg ${
          notification.type === 'error' ? 'bg-red-500' : 'bg-green-500'
        } text-white fade-in`}>
          {notification.type === 'error' ? (
            <AlertCircle size={20} className="mr-2" />
          ) : (
            <CheckCircle size={20} className="mr-2" />
          )}
          {notification.message}
        </div>
      )}

      {/* Mobile Menu Overlay */}
      {showMobileMenu && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
          onClick={() => setShowMobileMenu(false)}
        />
      )}

      {/* Sidebar */}
      <div className={`fixed md:static inset-y-0 left-0 z-50 w-64 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 transform ${
        showMobileMenu ? 'translate-x-0' : '-translate-x-full'
      } md:translate-x-0 transition-transform duration-200 ease-in-out flex flex-col`}>
        <div className="p-4 border-b border-gray-200 dark:border-gray-700">
          <h1 className="text-xl font-bold text-gray-800 dark:text-gray-100">Consumable Tracker</h1>
        </div>
        <div className="flex-1 overflow-y-auto">
          <nav className="p-2">
            {sidebarCategories.map(category => {
              if (category.type === 'divider') {
                return <div key={category._id} className="my-2 border-t border-gray-200 dark:border-gray-700" />;
              }
              return (
                <button
                  key={category._id}
                  className={`flex items-center w-full p-3 mb-1 rounded-lg transition-colors ${
                    activeTab === category._id 
                      ? 'bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300' 
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                  }`}
                  onClick={() => handleTabChange(category._id)}
                >
                  <span className="mr-3">{getIcon(category.icon)}</span>
                  {category.name}
                </button>
              );
            })}
          </nav>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 h-16 flex items-center justify-between px-4">
          <div className="flex items-center">
            <button
              className="md:hidden mr-3 p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
              onClick={() => setShowMobileMenu(!showMobileMenu)}
            >
              <Menu size={20} />
            </button>
            {activeTab === 'settings' && lastNonSettingsTab && (
              <button 
                onClick={() => setActiveTab(lastNonSettingsTab)}
                className="mr-3 p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                title="Back"
              >
                <ArrowLeft size={20} />
              </button>
            )}
            <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
              {activeCategory?.name || 
               (activeTab === 'all-consumables' ? 'All Consumables' : 
                activeTab === 'all-tasks' ? 'All Tasks' : 'Settings')}
            </h2>
          </div>
          <div className="flex items-center space-x-2">
            {/* View mode toggle */}
            {(isConsumableCategory || isTaskCategory || activeTab === 'all-consumables' || activeTab === 'all-tasks') && (
              <>
                <button
                  className={`p-2 rounded ${viewMode === 'grid' ? 'bg-gray-200 dark:bg-gray-700' : 'hover:bg-gray-100 dark:hover:bg-gray-700'}`}
                  onClick={() => setViewMode('grid')}
                  title="Grid view"
                >
                  <Grid size={20} />
                </button>
                <button
                  className={`p-2 rounded ${viewMode === 'list' ? 'bg-gray-200 dark:bg-gray-700' : 'hover:bg-gray-100 dark:hover:bg-gray-700'}`}
                  onClick={() => setViewMode('list')}
                  title="List view"
                >
                  <List size={20} />
                </button>
                
                {/* Sort options */}
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="px-3 py-1 border rounded-md text-sm dark:bg-gray-700 dark:border-gray-600"
                >
                  <option value="name">Sort by Name</option>
                  {(isConsumableCategory || activeTab === 'all-consumables') && (
                    <>
                      <option value="quantity">Sort by Quantity</option>
                      <option value="emptyDate">Sort by Empty Date</option>
                    </>
                  )}
                  {(isTaskCategory || activeTab === 'all-tasks') && (
                    <>
                      <option value="date">Sort by Due Date</option>
                      <option value="priority">Sort by Priority</option>
                    </>
                  )}
                </select>
                <button
                  onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
                  className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded"
                  title={`Sort ${sortOrder === 'asc' ? 'descending' : 'ascending'}`}
                >
                  {sortOrder === 'asc' ? <SortAsc size={20} /> : <SortDesc size={20} />}
                </button>
              </>
            )}
            
            {/* Dark mode toggle */}
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
              title={darkMode ? 'Light mode' : 'Dark mode'}
            >
              {darkMode ? <Sun size={20} /> : <Moon size={20} />}
            </button>
            
            <button className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
              <Bell size={20} />
            </button>
            <button className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
              <User size={20} />
            </button>
          </div>
        </header>

        {/* Content Area */}
        <main className="flex-1 overflow-y-auto p-4 bg-gray-50 dark:bg-gray-900">
          {error && <ErrorMessage message={error} onRetry={fetchData} />}
          
          {activeTab === 'settings' ? (
            <SettingsPanel 
              categories={categories} 
              onBackClick={lastNonSettingsTab ? () => setActiveTab(lastNonSettingsTab) : null}
              onForceAutoDecrease={handleForceAutoDecrease}
            />
          ) : (isTaskCategory || activeTab === 'all-tasks') ? (
            <TasksPanel 
              tasks={filteredTasks}
              onAdd={() => openAddModal('task')}
              onEdit={(task) => openEditModal('task', task)}
              onDelete={handleDeleteTask}
              onToggle={handleToggleTask}
              viewMode={viewMode}
              showAllCategories={activeTab === 'all-tasks'}
            />
          ) : (isConsumableCategory || activeTab === 'all-consumables') ? (
            <ConsumablesPanel
              consumables={filteredConsumables}
              onAdd={() => openAddModal('consumable')}
              onEdit={(item) => openEditModal('consumable', item)}
              onDelete={handleDeleteConsumable}
              onDecrease={handleDecreaseConsumable}
              onRefill={handleRefillConsumable}
              viewMode={viewMode}
              showAllCategories={activeTab === 'all-consumables'}
            />
          ) : (
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 text-center">
              <p className="text-gray-500 dark:text-gray-400 mb-4">No categories found. Create one to get started!</p>
              <div className="flex justify-center space-x-4">
                <button 
                  onClick={() => openAddModal('consumable')}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
                >
                  Add Consumable Category
                </button>
                <button 
                  onClick={() => openAddModal('task')}
                  className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg"
                >
                  Add Task Category
                </button>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Modals */}
      {showModal && modalType === 'consumable' && (
        <ConsumableModal
          show={showModal}
          onClose={() => setShowModal(false)}
          onSave={handleSaveConsumable}
          categories={categories.filter(c => c.type === 'consumable')}
          consumable={editingItem}
          onCategoryAdded={handleCategoryAdded}
        />
      )}
      
      {showModal && modalType === 'task' && (
        <TaskModal
          show={showModal}
          onClose={() => setShowModal(false)}
          onSave={handleSaveTask}
          categories={categories.filter(c => c.type === 'task')}
          task={editingItem}
          onCategoryAdded={handleCategoryAdded}
        />
      )}
    </div>
  );
}

// Sub-components
function ConsumablesPanel({ consumables, onAdd, onEdit, onDelete, onDecrease, onRefill, viewMode, showAllCategories }) {
  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {showAllCategories 
            ? `${consumables.length} items across all categories`
            : 'Track your household consumables'}
        </p>
        <button 
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center"
          onClick={onAdd}
        >
          <Plus size={16} className="mr-1" />
          Add Item
        </button>
      </div>
      
      {consumables.length === 0 ? (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-8 text-center">
          <p className="text-gray-500 dark:text-gray-400 mb-4">No items {showAllCategories ? '' : 'in this category'} yet.</p>
          <button 
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg inline-flex items-center"
            onClick={onAdd}
          >
            <Plus size={20} className="mr-2" />
            Add Your First Item
          </button>
        </div>
      ) : viewMode === 'list' ? (
        <div className="space-y-2">
          {consumables.map((item) => (
            <ConsumableCard
              key={item._id}
              consumable={item}
              onEdit={() => onEdit(item)}
              onDelete={() => onDelete(item._id)}
              onDecrease={() => onDecrease(item._id)}
              onRefill={() => onRefill(item._id)}
              viewMode="list"
            />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {consumables.map((item) => (
            <ConsumableCard
              key={item._id}
              consumable={item}
              onEdit={() => onEdit(item)}
              onDelete={() => onDelete(item._id)}
              onDecrease={() => onDecrease(item._id)}
              onRefill={() => onRefill(item._id)}
              viewMode="grid"
            />
          ))}
          
          <div 
            className="bg-white dark:bg-gray-800 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 flex items-center justify-center cursor-pointer hover:border-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors min-h-[200px]"
            onClick={onAdd}
          >
            <div className="text-center p-6">
              <div className="w-12 h-12 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center mx-auto mb-2">
                <Plus size={24} className="text-blue-600 dark:text-blue-400" />
              </div>
              <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Add New Item</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Track a new consumable</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function TasksPanel({ tasks, onAdd, onEdit, onDelete, onToggle, viewMode, showAllCategories }) {
  const [filter, setFilter] = useState('all');
  
  const filteredTasks = tasks.filter(task => {
    if (filter === 'active') return !task.completed;
    if (filter === 'completed') return task.completed;
    return true;
  });

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {showAllCategories 
            ? `${tasks.length} tasks across all categories`
            : 'Manage your recurring tasks and chores'}
        </p>
        <button 
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center"
          onClick={onAdd}
        >
          <Plus size={16} className="mr-1" />
          Add Task
        </button>
      </div>
      
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
        <div className="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <div className="flex space-x-4">
            <button 
              className={`px-3 py-1 rounded-md text-sm font-medium ${
                filter === 'all' 
                  ? 'bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300' 
                  : 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
              onClick={() => setFilter('all')}
            >
              All
            </button>
            <button 
              className={`px-3 py-1 rounded-md text-sm font-medium ${
                filter === 'active' 
                  ? 'bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300' 
                  : 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
              onClick={() => setFilter('active')}
            >
              Active
            </button>
            <button 
              className={`px-3 py-1 rounded-md text-sm font-medium ${
                filter === 'completed' 
                  ? 'bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300' 
                  : 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
              onClick={() => setFilter('completed')}
            >
              Completed
            </button>
          </div>
        </div>
        
        <ul className="divide-y divide-gray-200 dark:divide-gray-700">
          {filteredTasks.length === 0 ? (
            <li className="p-8 text-center">
              <p className="text-gray-500 dark:text-gray-400 mb-4">
                {filter === 'all' ? 'No tasks in this category yet.' : 
                 filter === 'active' ? 'No active tasks.' : 
                 'No completed tasks.'}
              </p>
              {filter === 'all' && (
                <button 
                  className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg inline-flex items-center"
                  onClick={onAdd}
                >
                  <Plus size={20} className="mr-2" />
                  Add Your First Task
                </button>
              )}
            </li>
          ) : (
            <>
              {filteredTasks.map(task => (
                <TaskItem
                  key={task._id}
                  task={task}
                  onToggle={() => onToggle(task._id)}
                  onEdit={() => onEdit(task)}
                  onDelete={() => onDelete(task._id)}
                  showCategory={showAllCategories}
                />
              ))}
              <li className="p-4 text-center">
                <button 
                  className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 text-sm font-medium flex items-center justify-center mx-auto"
                  onClick={onAdd}
                >
                  <Plus size={16} className="mr-1" />
                  Add New Task
                </button>
              </li>
            </>
          )}
        </ul>
      </div>
    </div>
  );
}

function SettingsPanel({ categories, onBackClick, onForceAutoDecrease }) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Application Settings</h3>
        {onBackClick && (
          <button 
            onClick={onBackClick}
            className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 flex items-center"
          >
            <ArrowLeft size={16} className="mr-1" />
            Back
          </button>
        )}
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h4 className="font-medium mb-3 text-gray-900 dark:text-gray-100">Categories</h4>
          {categories.length === 0 ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">No categories created yet.</p>
          ) : (
            <div className="space-y-2">
              {categories.map(category => (
                <div key={category._id} className="flex items-center justify-between p-3 border dark:border-gray-700 rounded-lg">
                  <div className="flex items-center">
                    <span className="mr-2 text-gray-900 dark:text-gray-100">{category.name}</span>
                    <span className="text-xs text-gray-500 dark:text-gray-400">({category.type})</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
        <div>
          <h4 className="font-medium mb-3 text-gray-900 dark:text-gray-100">Maintenance</h4>
          <button
            onClick={onForceAutoDecrease}
            className="mb-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
          >
            Force Auto-Decrease Now
          </button>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Consumable Tracker v1.0.0<br />
            Track household items and recurring tasks efficiently.<br /><br />
            Auto-decrease runs every hour automatically.<br />
            Dark mode is {localStorage.getItem('darkMode') === 'true' ? 'enabled' : 'disabled'}.
          </p>
        </div>
      </div>
    </div>
  );
}

export default App;
