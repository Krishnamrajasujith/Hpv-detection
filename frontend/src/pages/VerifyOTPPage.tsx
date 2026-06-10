import { useRef, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import api from '../lib/api'

export default function VerifyOTPPage() {
  const navigate = useNavigate()
  const { state } = useLocation() as { state: { email: string; purpose: string } }
  const [digits, setDigits] = useState(['', '', '', '', '', ''])
  const [loading, setLoading] = useState(false)
  const refs = Array.from({ length: 6 }, () => useRef<HTMLInputElement>(null))

  const onDigit = (i: number, val: string) => {
    if (!/^\d?$/.test(val)) return
    const next = [...digits]
    next[i] = val
    setDigits(next)
    if (val && i < 5) refs[i + 1].current?.focus()
  }

  const onKeyDown = (i: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !digits[i] && i > 0) refs[i - 1].current?.focus()
  }

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    const otp = digits.join('')
    if (otp.length < 6) { toast.error('Enter all 6 digits'); return }
    setLoading(true)
    try {
      await api.post('/auth/verify-otp', { email: state.email, otp, purpose: state.purpose })
      toast.success('OTP verified!')
      if (state.purpose === 'register') navigate('/login')
      else navigate('/reset-password', { state: { email: state.email } })
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Invalid OTP')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="card">
          <h1 className="text-light font-bold text-xl mb-2">Verify OTP</h1>
          <p className="text-muted text-sm mb-6">
            Enter the 6-digit code sent to <span className="text-accent">{state?.email}</span>
          </p>
          <form onSubmit={submit}>
            <div className="flex gap-2 justify-center mb-6">
              {refs.map((ref, i) => (
                <input
                  key={i}
                  ref={ref}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digits[i]}
                  onChange={(e) => onDigit(i, e.target.value)}
                  onKeyDown={(e) => onKeyDown(i, e)}
                  className="w-11 h-12 text-center text-xl font-bold bg-bg border border-border rounded-lg
                             text-light focus:outline-none focus:border-accent transition-colors"
                />
              ))}
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full">
              {loading ? 'Verifying…' : 'Verify'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
