interface BadgeProps {
  label: string
  variant?: 'success' | 'danger' | 'warn' | 'info'
}

const variants = {
  success: 'badge-success',
  danger: 'badge-danger',
  warn: 'badge-warn',
  info: 'badge-info',
}

export default function Badge({ label, variant = 'info' }: BadgeProps) {
  return <span className={variants[variant]}>{label}</span>
}

export function riskBadge(risk: string) {
  if (risk?.includes('High')) return <Badge label={risk} variant="danger" />
  if (risk?.includes('Moderate')) return <Badge label={risk} variant="warn" />
  return <Badge label={risk} variant="success" />
}

export function resultBadge(result: string) {
  return result?.includes('Positive')
    ? <Badge label={result} variant="danger" />
    : <Badge label={result} variant="success" />
}
