import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import api from '../lib/api'

export default function ForgotPasswordPage() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const { data } = await api.post('/auth/forgot-password', { email })
      if (data.dev_otp) toast(`Dev OTP: ${data.dev_otp}`, { icon: '🔑', duration: 15000 })
      toast.success('If that email is registered, an OTP has been sent.')
      navigate('/verify-otp', { state: { email, purpose: 'reset' } })
    } catch {
      toast.success('If that email is registered, an OTP has been sent.')
      navigate('/verify-otp', { state: { email, purpose: 'reset' } })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="card">
          <h1 className="text-light font-bold text-xl mb-2">Forgot Password</h1>
          <p className="text-muted text-sm mb-6">Enter your registered email to receive a reset OTP.</p>
          <form onSubmit={submit} className="space-y-4">
            <input
              type="email"
              className="input"
              placeholder="your@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <button type="submit" disabled={loading} className="btn-primary w-full">
              {loading ? 'Sending…' : 'Send OTP'}
            </button>
          </form>
          <div className="mt-4 text-sm text-center">
            <Link to="/login" className="text-accent hover:underline">Back to login</Link>
          </div>
        </div>
      </div>
    </div>
  )
}
