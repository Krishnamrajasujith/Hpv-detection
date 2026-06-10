import { useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import api from '../lib/api'

export default function ResetPasswordPage() {
  const navigate = useNavigate()
  const { state } = useLocation() as { state: { email: string } }
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      await api.post('/auth/reset-password', { email: state.email, password })
      toast.success('Password reset! Please log in.')
      navigate('/login')
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Reset failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="card">
          <h1 className="text-light font-bold text-xl mb-6">New Password</h1>
          <form onSubmit={submit} className="space-y-4">
            <input
              type="password"
              className="input"
              placeholder="min 6 characters"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              minLength={6}
              required
            />
            <button type="submit" disabled={loading} className="btn-primary w-full">
              {loading ? 'Saving…' : 'Reset Password'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
