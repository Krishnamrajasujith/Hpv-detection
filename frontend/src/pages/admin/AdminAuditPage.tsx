import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../../components/Layout'
import api from '../../lib/api'

const actionColors: Record<string, string> = {
  LOGIN: 'badge-info',
  LOGOUT: 'badge-info',
  REGISTER: 'badge-success',
  PREDICT: 'badge-success',
  TRAIN: 'badge-warn',
  DELETE_REPORT: 'badge-danger',
  PROFILE_UPDATE: 'badge-info',
  UPGRADE_USER: 'badge-warn',
  DELETE_USER: 'badge-danger',
  ADMIN_DELETE_REPORT: 'badge-danger',
  PASSWORD_RESET: 'badge-warn',
}

export default function AdminAuditPage() {
  const [logs, setLogs] = useState<any[]>([])
  const [search, setSearch] = useState('')
  const [filterAction, setFilterAction] = useState('All')

  useEffect(() => {
    api.get('/admin/audit').then(({ data }) => setLogs(data)).catch(() => toast.error('Failed to load audit log'))
  }, [])

  const actions = ['All', ...Array.from(new Set(logs.map((l) => l.action)))]

  const filtered = logs.filter((l) => {
    const q = search.toLowerCase()
    return (
      (l.username?.toLowerCase().includes(q) || l.detail?.toLowerCase().includes(q)) &&
      (filterAction === 'All' || l.action === filterAction)
    )
  })

  return (
    <Layout>
      <div className="max-w-6xl mx-auto space-y-6">
        <h1 className="text-light font-bold text-2xl">Audit Log</h1>

        <div className="flex flex-wrap gap-3">
          <input className="input flex-1 min-w-48 text-sm py-2" placeholder="Search user or detail…" value={search} onChange={(e) => setSearch(e.target.value)} />
          <select className="input w-44 text-sm py-2" value={filterAction} onChange={(e) => setFilterAction(e.target.value)}>
            {actions.map((a) => <option key={a}>{a}</option>)}
          </select>
        </div>

        <div className="card overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-muted text-xs uppercase">
                {['ID', 'User', 'Action', 'Detail', 'IP', 'Time'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left font-medium">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((l) => (
                <tr key={l.id} className="border-b border-border/50 hover:bg-white/[0.02]">
                  <td className="px-4 py-3 text-muted font-mono text-xs">{l.id}</td>
                  <td className="px-4 py-3 text-accent text-xs">{l.username}</td>
                  <td className="px-4 py-3">
                    <span className={`badge ${actionColors[l.action] ?? 'badge-info'}`}>{l.action}</span>
                  </td>
                  <td className="px-4 py-3 text-muted text-xs max-w-xs truncate">{l.detail}</td>
                  <td className="px-4 py-3 text-muted font-mono text-xs">{l.ip}</td>
                  <td className="px-4 py-3 text-muted text-xs whitespace-nowrap">{l.created_at}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  )
}
