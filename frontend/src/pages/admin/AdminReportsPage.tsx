import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../../components/Layout'
import { resultBadge, riskBadge } from '../../components/Badge'
import api from '../../lib/api'

interface Report {
  id: number; username: string; patient_name: string
  result: string; confidence: number; risk: string; created_at: string
}

export default function AdminReportsPage() {
  const [reports, setReports] = useState<Report[]>([])
  const [search, setSearch] = useState('')
  const [filterRisk, setFilterRisk] = useState('All')
  const [filterResult, setFilterResult] = useState('All')

  const load = () => api.get('/admin/reports').then(({ data }) => setReports(data)).catch(() => toast.error('Failed'))
  useEffect(() => { load() }, [])

  const remove = async (id: number) => {
    if (!confirm('Delete this report?')) return
    try {
      await api.delete(`/admin/reports/${id}`)
      toast.success('Deleted')
      setReports((r) => r.filter((x) => x.id !== id))
    } catch { toast.error('Failed') }
  }

  const filtered = reports.filter((r) => {
    const q = search.toLowerCase()
    return (
      (r.patient_name?.toLowerCase().includes(q) || r.username?.toLowerCase().includes(q)) &&
      (filterRisk === 'All' || r.risk?.includes(filterRisk)) &&
      (filterResult === 'All' || r.result?.includes(filterResult))
    )
  })

  return (
    <Layout>
      <div className="max-w-6xl mx-auto space-y-6">
        <h1 className="text-light font-bold text-2xl">Manage Reports</h1>

        <div className="flex flex-wrap gap-3">
          <input className="input flex-1 min-w-48 text-sm py-2" placeholder="Search patient or user…" value={search} onChange={(e) => setSearch(e.target.value)} />
          <select className="input w-40 text-sm py-2" value={filterRisk} onChange={(e) => setFilterRisk(e.target.value)}>
            <option>All</option><option>High</option><option>Moderate</option><option>Low</option>
          </select>
          <select className="input w-40 text-sm py-2" value={filterResult} onChange={(e) => setFilterResult(e.target.value)}>
            <option>All</option><option>Positive</option><option>Negative</option>
          </select>
        </div>

        <div className="card overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-muted text-xs uppercase">
                {['ID', 'User', 'Patient', 'Result', 'Confidence', 'Risk', 'Date', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left font-medium">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => (
                <tr key={r.id} className="border-b border-border/50 hover:bg-white/[0.02]">
                  <td className="px-4 py-3 text-muted font-mono text-xs">#{r.id}</td>
                  <td className="px-4 py-3 text-accent text-xs">{r.username}</td>
                  <td className="px-4 py-3 text-light">{r.patient_name}</td>
                  <td className="px-4 py-3">{resultBadge(r.result)}</td>
                  <td className="px-4 py-3 text-light text-xs">{r.confidence?.toFixed(1)}%</td>
                  <td className="px-4 py-3">{riskBadge(r.risk)}</td>
                  <td className="px-4 py-3 text-muted text-xs">{r.created_at ? new Date(r.created_at).toLocaleDateString() : '—'}</td>
                  <td className="px-4 py-3">
                    <button onClick={() => remove(r.id)} className="text-xs text-danger hover:underline">Delete</button>
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
