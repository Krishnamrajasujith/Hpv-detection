import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import Layout from '../../components/Layout'
import { resultBadge, riskBadge } from '../../components/Badge'
import api from '../../lib/api'

export default function AdminPage() {
  const [stats, setStats] = useState<any>(null)

  useEffect(() => {
    api.get('/admin/stats')
      .then(({ data }) => setStats(data))
      .catch(() => toast.error('Failed to load stats'))
  }, [])

  const cards = stats
    ? [
        { label: 'Total Users', value: stats.total_users, color: 'text-accent' },
        { label: 'Total Reports', value: stats.total_reports, color: 'text-cyan' },
        { label: 'HPV Positive', value: stats.positive, color: 'text-danger' },
        { label: 'HPV Negative', value: stats.negative, color: 'text-teal' },
      ]
    : []

  return (
    <Layout>
      <div className="max-w-5xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-light font-bold text-2xl">Admin Overview</h1>
          <span className="badge badge-warn">Admin</span>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {cards.map(({ label, value, color }) => (
            <div key={label} className="card text-center">
              <div className={`text-3xl font-bold ${color}`}>{value ?? '—'}</div>
              <div className="text-muted text-sm mt-1">{label}</div>
            </div>
          ))}
        </div>

        <div className="grid md:grid-cols-3 gap-4">
          {[
            { to: '/admin/users', label: 'Manage Users', icon: '◎', desc: 'View, upgrade, delete users' },
            { to: '/admin/reports', label: 'Manage Reports', icon: '▤', desc: 'View and delete all reports' },
            { to: '/admin/audit', label: 'Audit Log', icon: '▣', desc: 'Track all platform actions' },
          ].map(({ to, label, icon, desc }) => (
            <Link key={to} to={to} className="card hover:border-accent/60 transition-colors group">
              <div className="text-2xl mb-2">{icon}</div>
              <div className="text-light font-semibold group-hover:text-accent transition-colors">{label}</div>
              <div className="text-muted text-sm mt-1">{desc}</div>
            </Link>
          ))}
        </div>

        {stats?.recent_reports?.length > 0 && (
          <div className="card">
            <h2 className="text-light font-semibold mb-4">Recent Reports</h2>
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border text-muted text-xs uppercase">
                  <th className="pb-2 text-left">User</th>
                  <th className="pb-2 text-left">Patient</th>
                  <th className="pb-2 text-left">Result</th>
                  <th className="pb-2 text-left">Risk</th>
                  <th className="pb-2 text-left">Date</th>
                </tr>
              </thead>
              <tbody>
                {stats.recent_reports.map((r: any) => (
                  <tr key={r.id} className="border-b border-border/50 hover:bg-white/[0.02]">
                    <td className="py-2 text-accent text-xs">{r.username}</td>
                    <td className="py-2 text-light">{r.patient_name}</td>
                    <td className="py-2">{resultBadge(r.result)}</td>
                    <td className="py-2">{riskBadge(r.risk)}</td>
                    <td className="py-2 text-muted text-xs">
                      {r.created_at ? new Date(r.created_at).toLocaleDateString() : '—'}
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
