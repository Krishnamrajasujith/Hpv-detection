import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
      <Toaster
        position="top-right"
        toastOptions={{
          style: {
            background: '#0d1a2e',
            color: '#b0c4de',
            border: '1px solid #1e3a5f',
            fontFamily: '"DM Sans", sans-serif',
          },
          success: { iconTheme: { primary: '#0ee7b0', secondary: '#070d1a' } },
          error: { iconTheme: { primary: '#ff4f6d', secondary: '#070d1a' } },
        }}
      />
    </BrowserRouter>
  </React.StrictMode>,
)
