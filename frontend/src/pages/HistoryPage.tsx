import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../components/Layout'
import { riskBadge, resultBadge } from '../components/Badge'
import api from '../lib/api'

interface HistoryItem {
  id: number
  patient_name: string
  result: string
  confidence: number
  risk: string
  image: string
  created_at: string
  sample_id: string
}

async function downloadPdf(id: number) {
  try {
    const { data } = await api.get(`/predictions/download/${id}`, { responseType: 'blob' })
    const url = URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url; a.download = `report_${id}.pdf`
    document.body.appendChild(a); a.click()
    document.body.removeChild(a); URL.revokeObjectURL(url)
  } catch { toast.error('Download failed') }
}

async function viewQr(id: number) {
  try {
    const { data } = await api.get(`/predictions/qr/${id}`, { responseType: 'blob' })
    window.open(URL.createObjectURL(data), '_blank')
  } catch { toast.error('Failed to load QR code') }
}

export default function HistoryPage() {
  const [items, setItems] = useState<HistoryItem[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filterRisk, setFilterRisk] = useState('All')
  const [filterResult, setFilterResult] = useState('All')

  const load = () => {
    api.get('/predictions/history')
      .then(({ data }) => setItems(data))
      .catch(() => toast.error('Failed to load history'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this report?')) return
    try {
      await api.delete(`/predictions/history/${id}`)
      toast.success('Report deleted')
      setItems((prev) => prev.filter((i) => i.id !== id))
    } catch {
      toast.error('Delete failed')
    }
  }

  const filtered = items.filter((i) => {
    const matchSearch = i.patient_name.toLowerCase().includes(search.toLowerCase()) ||
      i.sample_id?.toLowerCase().includes(search.toLowerCase())
    const matchRisk = filterRisk === 'All' || i.risk?.includes(filterRisk)
    const matchResult = filterResult === 'All' || i.result?.includes(filterResult)
    return matchSearch && matchRisk && matchResult
  })

  return (
    <Layout>
      <div className="max-w-6xl mx-auto space-y-6">
        <h1 className="text-light font-bold text-2xl">Prediction History</h1>

        <div className="flex flex-wrap gap-3">
          <input
            className="input flex-1 min-w-48 text-sm py-2"
            placeholder="Search patient or sample ID…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <select className="input w-40 text-sm py-2" value={filterRisk} onChange={(e) => setFilterRisk(e.target.value)}>
            <option>All</option>
            <option>High</option>
            <option>Moderate</option>
            <option>Low</option>
          </select>
          <select className="input w-40 text-sm py-2" value={filterResult} onChange={(e) => setFilterResult(e.target.value)}>
            <option>All</option>
            <option>Positive</option>
            <option>Negative</option>
          </select>
        </div>

        {loading ? (
          <div className="text-muted text-center py-12">Loading…</div>
        ) : filtered.length === 0 ? (
          <div className="card text-center py-12 text-muted">
            No predictions found.{' '}
            <a href="/dashboard" className="text-accent hover:underline">Run your first →</a>
          </div>
        ) : (
          <div className="card overflow-x-auto p-0">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border text-muted text-xs uppercase">
                  {['Patient', 'Sample ID', 'Result', 'Confidence', 'Risk', 'Date', 'Actions'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left font-medium">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((item) => (
                  <tr key={item.id} className="border-b border-border/50 hover:bg-white/[0.02] transition-colors">
                    <td className="px-4 py-3 text-light font-medium">{item.patient_name}</td>
                    <td className="px-4 py-3 text-muted font-mono text-xs">{item.sample_id}</td>
                    <td className="px-4 py-3">{resultBadge(item.result)}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-1.5 bg-border rounded-full overflow-hidden w-16">
                          <div
                            className="h-full bg-accent rounded-full"
                            style={{ width: `${item.confidence}%` }}
                          />
                        </div>
                        <span className="text-light text-xs">{item.confidence?.toFixed(1)}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">{riskBadge(item.risk)}</td>
                    <td className="px-4 py-3 text-muted text-xs">
                      {item.created_at ? new Date(item.created_at).toLocaleDateString() : '—'}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex gap-2">
                        <button
                          onClick={() => downloadPdf(item.id)}
                          className="text-xs text-accent hover:underline"
                        >
                          PDF
                        </button>
                        <button
                          onClick={() => viewQr(item.id)}
                          className="text-xs text-cyan hover:underline"
                        >
                          QR
                        </button>
                        <button
                          onClick={() => handleDelete(item.id)}
                          className="text-xs text-danger hover:underline"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </Layout>
  )
}
