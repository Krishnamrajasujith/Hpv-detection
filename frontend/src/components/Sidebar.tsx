import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuthStore } from '../store/authStore'
import api from '../lib/api'

const userNav = [
  { path: '/dashboard', label: 'Dashboard', icon: '⊞' },
  { path: '/history', label: 'History', icon: '◷' },
  { path: '/profile', label: 'Profile', icon: '◉' },
]

const adminNav = [
  { path: '/admin', label: 'Overview', icon: '▦' },
  { path: '/admin/users', label: 'Users', icon: '◎' },
  { path: '/admin/reports', label: 'Reports', icon: '▤' },
  { path: '/admin/audit', label: 'Audit Log', icon: '▣' },
]

export default function Sidebar() {
  const { pathname } = useLocation()
  const navigate = useNavigate()
  const { user, logout } = useAuthStore()

  const handleLogout = async () => {
    await api.post('/auth/logout').catch(() => null)
    logout()
    navigate('/login')
  }

  const navLinks = user?.role === 'admin' ? [...userNav, ...adminNav] : userNav

  return (
    <>
      {/* Desktop sidebar */}
      <aside className="hidden md:flex flex-col w-60 min-h-screen bg-surface border-r border-border fixed left-0 top-0 z-30">
        <div className="px-6 py-5 border-b border-border">
          <div className="text-accent font-bold text-lg">HPV DetectAI</div>
          <div className="text-muted text-xs mt-0.5">Genomic Diagnostics</div>
        </div>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {navLinks.map(({ path, label, icon }) => (
            <Link
              key={path}
              to={path}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors
                ${pathname === path || pathname.startsWith(path + '/')
                  ? 'bg-accent/20 text-accent'
                  : 'text-light hover:bg-white/5'}`}
            >
              <span className="text-base">{icon}</span>
              {label}
            </Link>
          ))}
        </nav>

        <div className="px-3 py-4 border-t border-border">
          <div className="px-3 py-2 text-xs text-muted mb-2">
            <span className="text-light font-medium">{user?.username}</span>
            {' · '}
            <span className={user?.role === 'admin' ? 'text-warn' : 'text-teal'}>{user?.role}</span>
          </div>
          <button
            onClick={handleLogout}
            className="w-full text-left flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-danger hover:bg-danger/10 transition-colors"
          >
            <span>⎋</span> Logout
          </button>
        </div>
      </aside>

      {/* Mobile bottom bar */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-surface border-t border-border z-30 flex">
        {navLinks.slice(0, 4).map(({ path, label, icon }) => (
          <Link
            key={path}
            to={path}
            className={`flex-1 flex flex-col items-center py-3 text-xs transition-colors
              ${pathname === path ? 'text-accent' : 'text-muted'}`}
          >
            <span className="text-xl mb-0.5">{icon}</span>
            {label}
          </Link>
        ))}
        <button
          onClick={handleLogout}
          className="flex-1 flex flex-col items-center py-3 text-xs text-danger"
        >
          <span className="text-xl mb-0.5">⎋</span>
          Logout
        </button>
      </nav>
    </>
  )
}
