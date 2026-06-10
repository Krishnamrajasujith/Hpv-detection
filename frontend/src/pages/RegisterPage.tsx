import { useState, useEffect, useRef } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import api from '../lib/api'

type EmailStatus = 'idle' | 'checking' | 'valid' | 'invalid'

export default function RegisterPage() {
  const navigate = useNavigate()
  const [form, setForm] = useState({ username: '', password: '', email: '', mobile: '' })
  const [loading, setLoading] = useState(false)
  const [emailStatus, setEmailStatus] = useState<EmailStatus>('idle')
  const [emailMsg, setEmailMsg] = useState('')
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const strength = (p: string) => {
    if (p.length === 0) return null
    if (p.length < 6) return { label: 'Too short', color: 'bg-danger', w: 'w-1/4' }
    if (p.length < 8) return { label: 'Weak', color: 'bg-warn', w: 'w-2/4' }
    if (/[A-Z]/.test(p) && /\d/.test(p)) return { label: 'Strong', color: 'bg-teal', w: 'w-full' }
    return { label: 'Good', color: 'bg-accent', w: 'w-3/4' }
  }

  const pw = strength(form.password)

  useEffect(() => {
    const email = form.email.trim()
    if (!email || !email.includes('@')) {
      setEmailStatus('idle')
      setEmailMsg('')
      return
    }
    setEmailStatus('checking')
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(async () => {
      try {
        const { data } = await api.get(`/auth/validate-email?email=${encodeURIComponent(email)}`)
        setEmailStatus(data.valid ? 'valid' : 'invalid')
        setEmailMsg(data.reason ?? '')
      } catch {
        setEmailStatus('idle')
      }
    }, 600)
    return () => { if (debounceRef.current) clearTimeout(debounceRef.current) }
  }, [form.email])

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (emailStatus === 'invalid') { toast.error(emailMsg || 'Invalid email'); return }
    setLoading(true)
    try {
      await api.post('/auth/register', form)
      toast.success('OTP sent! Check your email.')
      navigate('/verify-otp', { state: { email: form.email, purpose: 'register' } })
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  const emailBorder =
    emailStatus === 'valid' ? 'border-teal' :
    emailStatus === 'invalid' ? 'border-danger' :
    emailStatus === 'checking' ? 'border-accent/60' : ''

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="text-accent font-bold text-2xl">HPV DetectAI</div>
          <div className="text-muted text-sm mt-1">Create your account</div>
        </div>

        <div className="card">
          <h1 className="text-light font-bold text-xl mb-6">Register</h1>
          <form onSubmit={submit} className="space-y-4">
            <div>
              <label className="block text-sm text-muted mb-1">Username</label>
              <input
                type="text"
                className="input"
                placeholder="choose a username"
                value={form.username}
                onChange={(e) => setForm({ ...form, username: e.target.value })}
                required
              />
            </div>

            <div>
              <label className="block text-sm text-muted mb-1">Email</label>
              <div className="relative">
                <input
                  type="email"
                  className={`input pr-8 ${emailBorder}`}
                  placeholder="your@email.com"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  required
                />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm">
                  {emailStatus === 'checking' && <span className="text-muted animate-pulse">...</span>}
                  {emailStatus === 'valid' && <span className="text-teal">✓</span>}
                  {emailStatus === 'invalid' && <span className="text-danger">✗</span>}
                </span>
              </div>
              {emailStatus === 'invalid' && (
                <p className="text-xs text-danger mt-1">{emailMsg}</p>
              )}
            </div>

            <div>
              <label className="block text-sm text-muted mb-1">Mobile (optional)</label>
              <input
                type="tel"
                className="input"
                placeholder="+91 9999999999"
                value={form.mobile}
                onChange={(e) => setForm({ ...form, mobile: e.target.value })}
              />
            </div>

            <div>
              <label className="block text-sm text-muted mb-1">Password</label>
              <input
                type="password"
                className="input"
                placeholder="min 6 characters"
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                required
              />
              {pw && (
                <div className="mt-2">
                  <div className="h-1.5 bg-border rounded-full overflow-hidden">
                    <div className={`h-full ${pw.color} ${pw.w} transition-all`} />
                  </div>
                  <div className="text-xs mt-1 text-muted">{pw.label}</div>
                </div>
              )}
            </div>

            <button
              type="submit"
              disabled={loading || emailStatus === 'invalid' || emailStatus === 'checking'}
              className="btn-primary w-full"
            >
              {loading ? 'Creating account…' : 'Create Account'}
            </button>
          </form>

          <div className="mt-4 text-sm text-center">
            <span className="text-muted">Already have an account? </span>
            <Link to="/login" className="text-accent hover:underline">Sign in</Link>
          </div>
        </div>
      </div>
    </div>
  )
}
