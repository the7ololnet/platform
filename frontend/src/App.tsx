import { useEffect, useState } from 'react'
import './App.css'

interface HealthStatus {
  status: string
  service: string
  environment: string
}

function App() {
  const [health, setHealth] = useState<HealthStatus | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetch('/health')
      .then(res => res.json())
      .then(data => {
        setHealth(data)
        setLoading(false)
      })
      .catch(err => {
        setError(err.message)
        setLoading(false)
      })
  }, [])

  return (
    <div className="app">
      <header className="app-header">
        <h1>📧 Email Marketing Platform</h1>
        <p className="subtitle">High Inbox Deliverability Solution</p>
      </header>

      <main className="app-main">
        <div className="status-card">
          <h2>System Status</h2>
          {loading && <p>Loading...</p>}
          {error && <p className="error">Error: {error}</p>}
          {health && (
            <div className="status-info">
              <p>
                <strong>Status:</strong>{' '}
                <span className={`status-badge ${health.status}`}>{health.status}</span>
              </p>
              <p>
                <strong>Service:</strong> {health.service}
              </p>
              <p>
                <strong>Environment:</strong> {health.environment}
              </p>
            </div>
          )}
        </div>

        <div className="info-card">
          <h2>About</h2>
          <p>
            This platform provides enterprise-grade email marketing capabilities with a focus on
            high inbox deliverability rates.
          </p>
          <p>
            <strong>Phase:</strong> 0 - Project Setup Complete
          </p>
        </div>
      </main>

      <footer className="app-footer">
        <p>Email Marketing Platform v0.1.0</p>
      </footer>
    </div>
  )
}

export default App
