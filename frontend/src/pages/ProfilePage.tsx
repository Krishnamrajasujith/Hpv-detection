import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../components/Layout'
import api from '../lib/api'

interface Profile { id: number; username: string; email: string; mobile: string; role: string }

export default function ProfilePage() {
  const [profile, setProfile] = useState<Profile | null>(null)
  const [editing, setEditing] = useState(false)
  const [form, setForm] = useState({ email: '', mobile: '' })
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    api.get('/users/me').then(({ data }) => {
      setProfile(data)
      setForm({ email: data.email, mobile: data.mobile })
    }).catch(() => toast.error('Failed to load profile'))
  }, [])

  const completion = profile
    ? [profile.email, profile.mobile].filter(Boolean).length / 2 * 100
    : 0

  const save = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    try {
      const { data } = await api.patch('/users/me', form)
      setProfile(data)
      setEditing(false)
      toast.success('Profile updated')
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Update failed')
    } finally {
      setSaving(false)
    }
  }

  if (!profile) return <Layout><div className="text-muted text-center py-16">Loading…</div></Layout>

  return (
    <Layout>
      <div className="max-w-xl mx-auto space-y-6">
        <h1 className="text-light font-bold text-2xl">Profile</h1>

        <div className="card space-y-5">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-full bg-accent/20 flex items-center justify-center text-2xl font-bold text-accent">
              {profile.username[0].toUpperCase()}
            </div>
            <div>
              <div className="text-light font-semibold text-lg">{profile.username}</div>
              <span className={`badge ${profile.role === 'admin' ? 'badge-warn' : 'badge-info'}`}>
                {profile.role}
              </span>
            </div>
          </div>

          <div>
            <div className="flex justify-between text-xs text-muted mb-1">
              <span>Profile completion</span>
              <span>{completion.toFixed(0)}%</span>
            </div>
            <div className="h-1.5 bg-border rounded-full overflow-hidden">
              <div className="h-full bg-teal rounded-full transition-all" style={{ width: `${completion}%` }} />
            </div>
          </div>

          {editing ? (
            <form onSubmit={save} className="space-y-4">
              <div>
                <label className="block text-sm text-muted mb-1">Email</label>
                <input
                  type="email"
                  className="input"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                />
              </div>
              <div>
                <label className="block text-sm text-muted mb-1">Mobile</label>
                <input
                  type="tel"
                  className="input"
                  value={form.mobile}
                  onChange={(e) => setForm({ ...form, mobile: e.target.value })}
                />
              </div>
              <div className="flex gap-3">
                <button type="submit" disabled={saving} className="btn-primary flex-1">
                  {saving ? 'Saving…' : 'Save Changes'}
                </button>
                <button type="button" onClick={() => setEditing(false)} className="btn-ghost flex-1">
                  Cancel
                </button>
              </div>
            </form>
          ) : (
            <div className="space-y-3">
              {[
                { label: 'Email', value: profile.email || '—' },
                { label: 'Mobile', value: profile.mobile || '—' },
              ].map(({ label, value }) => (
                <div key={label} className="flex justify-between py-2 border-b border-border/50">
                  <span className="text-muted text-sm">{label}</span>
                  <span className="text-light text-sm">{value}</span>
                </div>
              ))}
              <button onClick={() => setEditing(true)} className="btn-ghost w-full mt-2">
                Edit Profile
              </button>
            </div>
          )}
        </div>
      </div>
    </Layout>
  )
}
