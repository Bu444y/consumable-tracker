import React from 'react';

function LoadingSpinner({ fullScreen = false }) {
  if (fullScreen) {
    return (
      <div className="flex items-center justify-center h-screen bg-gray-100">
        <div className="spinner"></div>
      </div>
    );
  }
  
  return (
    <div className="flex items-center justify-center p-8">
      <div className="spinner"></div>
    </div>
  );
}

export default LoadingSpinner;
