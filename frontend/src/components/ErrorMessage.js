import React from 'react';
import { AlertCircle } from 'lucide-react';

function ErrorMessage({ message, onRetry }) {
  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start">
      <AlertCircle className="text-red-500 mr-3 flex-shrink-0" size={20} />
      <div className="flex-1">
        <p className="text-red-800">{message}</p>
        {onRetry && (
          <button 
            onClick={onRetry}
            className="mt-2 text-sm text-red-600 hover:text-red-800 underline"
          >
            Try again
          </button>
        )}
      </div>
    </div>
  );
}

export default ErrorMessage;
