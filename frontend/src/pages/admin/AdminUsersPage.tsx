import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../../components/Layout'
import api from '../../lib/api'

interface User { id: number; username: string; email: string; mobile: string; role: string }

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [search, setSearch] = useState('')

  const load = () => api.get('/admin/users').then(({ data }) => setUsers(data)).catch(() => toast.error('Failed to load users'))
  useEffect(() => { load() }, [])

  const upgrade = async (id: number, name: string) => {
    if (!confirm(`Promote ${name} to admin?`)) return
    try {
      await api.post(`/admin/users/${id}/upgrade`)
      toast.success(`${name} is now admin`)
      load()
    } catch { toast.error('Failed') }
  }

  const remove = async (id: number, name: string) => {
    if (!confirm(`Delete user ${name} and ALL their reports?`)) return
    try {
      await api.delete(`/admin/users/${id}`)
      toast.success(`${name} deleted`)
      setUsers((u) => u.filter((x) => x.id !== id))
    } catch { toast.error('Failed') }
  }

  const filtered = users.filter(
    (u) => u.username.toLowerCase().includes(search.toLowerCase()) ||
           u.email.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <Layout>
      <div className="max-w-5xl mx-auto space-y-6">
        <h1 className="text-light font-bold text-2xl">Manage Users</h1>

        <input
          className="input max-w-sm text-sm py-2"
          placeholder="Search username or email…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />

        <div className="card overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-muted text-xs uppercase">
                {['ID', 'Username', 'Email', 'Mobile', 'Role', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left font-medium">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((u) => (
                <tr key={u.id} className="border-b border-border/50 hover:bg-white/[0.02]">
                  <td className="px-4 py-3 text-muted font-mono text-xs">{u.id}</td>
                  <td className="px-4 py-3 text-light font-medium">{u.username}</td>
                  <td className="px-4 py-3 text-muted">{u.email || '—'}</td>
                  <td className="px-4 py-3 text-muted">{u.mobile || '—'}</td>
                  <td className="px-4 py-3">
                    <span className={`badge ${u.role === 'admin' ? 'badge-warn' : 'badge-info'}`}>{u.role}</span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-3">
                      {u.role !== 'admin' && (
                        <button onClick={() => upgrade(u.id, u.username)} className="text-xs text-warn hover:underline">
                          Upgrade
                        </button>
                      )}
                      <button onClick={() => remove(u.id, u.username)} className="text-xs text-danger hover:underline">
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  )
}
