import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import api from '../lib/api'
import { useAuthStore } from '../store/authStore'

export default function LoginPage() {
  const navigate = useNavigate()
  const setUser = useAuthStore((s) => s.setUser)
  const [form, setForm] = useState({ username: '', password: '' })
  const [loading, setLoading] = useState(false)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const { data } = await api.post('/auth/login', form)
      setUser({ username: data.username, role: data.role, token: data.access_token })
      toast.success(`Welcome back, ${data.username}!`)
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="text-accent font-bold text-2xl">HPV DetectAI</div>
          <div className="text-muted text-sm mt-1">Genomic Diagnostics Platform</div>
        </div>

        <div className="card">
          <h1 className="text-light font-bold text-xl mb-6">Sign In</h1>
          <form onSubmit={submit} className="space-y-4">
            <div>
              <label className="block text-sm text-muted mb-1">Username</label>
              <input
                className="input"
                placeholder="your username"
                value={form.username}
                onChange={(e) => setForm({ ...form, username: e.target.value })}
                required
              />
            </div>
            <div>
              <label className="block text-sm text-muted mb-1">Password</label>
              <input
                type="password"
                className="input"
                placeholder="••••••••"
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                required
              />
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full">
              {loading ? 'Signing in…' : 'Sign In'}
            </button>
          </form>

          <div className="mt-4 text-sm text-center space-y-2">
            <Link to="/forgot-password" className="text-accent hover:underline block">
              Forgot password?
            </Link>
            <span className="text-muted">No account? </span>
            <Link to="/register" className="text-accent hover:underline">Register</Link>
          </div>
        </div>
      </div>
    </div>
  )
}
