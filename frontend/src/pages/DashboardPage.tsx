import { useEffect, useState } from 'react'
import toast from 'react-hot-toast'
import Layout from '../components/Layout'
import FileDropzone from '../components/FileDropzone'
import { riskBadge, resultBadge } from '../components/Badge'
import api from '../lib/api'

export default function DashboardPage() {

  const [trained, setTrained] = useState(false)
  const [trainFile, setTrainFile] = useState<File | null>(null)
  const [training, setTraining] = useState(false)
  const [predictFile, setPredictFile] = useState<File | null>(null)
  const [predicting, setPredicting] = useState(false)
  const [result, setResult] = useState<any>(null)
  const [patient, setPatient] = useState({
    patient_name: '', age: '', gender: 'Female',
    sample_id: '', test_date: '', notes: '',
    next_visit_date: '', daily_food_intake: '',
  })

  useEffect(() => {
    api.get('/predictions/model-status').then(({ data }) => setTrained(data.trained)).catch(() => null)
  }, [])

  const handleTrain = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!trainFile) { toast.error('Select a CSV file'); return }
    const fd = new FormData()
    fd.append('file', trainFile)
    setTraining(true)
    try {
      const { data } = await api.post('/predictions/train', fd)
      toast.success(`Model trained! Accuracy: ${data.accuracy}%`)
      setTrained(true)
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Training failed')
    } finally {
      setTraining(false)
    }
  }

  const handlePredict = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!predictFile) { toast.error('Select a CSV file'); return }
    const fd = new FormData()
    fd.append('file', predictFile)
    Object.entries(patient).forEach(([k, v]) => fd.append(k, v))
    setPredicting(true)
    setResult(null)
    try {
      const { data } = await api.post('/predictions/predict', fd)
      setResult(data)
      toast.success('Prediction complete!')
    } catch (err: any) {
      toast.error(err.response?.data?.detail ?? 'Prediction failed')
    } finally {
      setPredicting(false)
    }
  }

  return (
    <Layout>
      <div className="max-w-5xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-light font-bold text-2xl">Dashboard</h1>
          <span className={`badge ${trained ? 'badge-success' : 'badge-warn'}`}>
            {trained ? '● Model Ready' : '○ Model Not Trained'}
          </span>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Train */}
          <div className="card space-y-4">
            <h2 className="text-light font-semibold text-lg">Train Model</h2>
            <p className="text-muted text-sm">Upload a labelled CSV with HPV_Status column and 28 gene columns.</p>
            <form onSubmit={handleTrain} className="space-y-4">
              <FileDropzone label="Upload training CSV" onFile={setTrainFile} />
              <button type="submit" disabled={training} className="btn-teal w-full">
                {training ? 'Training…' : 'Train Model'}
              </button>
            </form>
          </div>

          {/* Predict */}
          <div className="card space-y-4">
            <h2 className="text-light font-semibold text-lg">New Prediction</h2>
            <form onSubmit={handlePredict} className="space-y-3">
              {[
                { key: 'patient_name', label: 'Patient Name', type: 'text', placeholder: 'Full name' },
                { key: 'age', label: 'Age', type: 'number', placeholder: 'Age' },
                { key: 'sample_id', label: 'Sample ID', type: 'text', placeholder: 'e.g. S-001' },
                { key: 'test_date', label: 'Test Date', type: 'date', placeholder: '' },
              ].map(({ key, label, type, placeholder }) => (
                <div key={key}>
                  <label className="block text-xs text-muted mb-1">{label}</label>
                  <input
                    type={type}
                    className="input text-sm py-2"
                    placeholder={placeholder}
                    value={(patient as any)[key]}
                    onChange={(e) => setPatient({ ...patient, [key]: e.target.value })}
                    required
                  />
                </div>
              ))}
              <div>
                <label className="block text-xs text-muted mb-1">Gender</label>
                <select
                  className="input text-sm py-2"
                  value={patient.gender}
                  onChange={(e) => setPatient({ ...patient, gender: e.target.value })}
                >
                  <option>Female</option><option>Male</option><option>Other</option>
                </select>
              </div>
              <div>
                <label className="block text-xs text-muted mb-1">Clinical Notes (optional)</label>
                <textarea
                  className="input text-sm py-2 resize-none"
                  rows={2}
                  value={patient.notes}
                  onChange={(e) => setPatient({ ...patient, notes: e.target.value })}
                />
              </div>
              <div>
                <label className="block text-xs text-muted mb-1">Next Visit Date</label>
                <input
                  type="date"
                  className="input text-sm py-2"
                  value={patient.next_visit_date}
                  onChange={(e) => setPatient({ ...patient, next_visit_date: e.target.value })}
                />
              </div>
              <div>
                <label className="block text-xs text-muted mb-1">
                  Daily Food Intake
                  <span className="ml-1 text-muted font-normal">(one item per line or semicolon-separated)</span>
                </label>
                <textarea
                  className="input text-sm py-2 resize-none"
                  rows={3}
                  placeholder={"e.g.\nRice, vegetables\nFruits\nMilk"}
                  value={patient.daily_food_intake}
                  onChange={(e) => setPatient({ ...patient, daily_food_intake: e.target.value })}
                />
              </div>
              <FileDropzone label="Upload gene expression CSV" onFile={setPredictFile} />
              <button type="submit" disabled={predicting || !trained} className="btn-primary w-full">
                {predicting ? 'Analysing…' : trained ? 'Run Prediction' : 'Train model first'}
              </button>
            </form>
          </div>
        </div>

        {result && (
          <div className="card space-y-4">
            <h2 className="text-light font-semibold text-lg">Result</h2>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-bg rounded-lg p-4 text-center">
                <div className="text-xs text-muted mb-1">Prediction</div>
                {resultBadge(result.result)}
              </div>
              <div className="bg-bg rounded-lg p-4 text-center">
                <div className="text-xs text-muted mb-1">Confidence</div>
                <div className="text-accent font-bold text-xl">{result.confidence.toFixed(1)}%</div>
              </div>
              <div className="bg-bg rounded-lg p-4 text-center">
                <div className="text-xs text-muted mb-1">Risk Level</div>
                {riskBadge(result.risk)}
              </div>
              <div className="bg-bg rounded-lg p-4 text-center">
                <div className="text-xs text-muted mb-1">Report ID</div>
                <div className="text-light font-bold">#{result.id}</div>
              </div>
            </div>
            {result.heatmap_url && (
              <img src={result.heatmap_url} alt="Gene expression heatmap" className="w-full rounded-lg" />
            )}
            <div className="flex gap-3">
              <button
                className="btn-ghost text-sm"
                onClick={async () => {
                  try {
                    const { data } = await api.get(`/predictions/download/${result.id}`, { responseType: 'blob' })
                    const url = URL.createObjectURL(data)
                    const a = document.createElement('a')
                    a.href = url; a.download = `report_${result.id}.pdf`
                    document.body.appendChild(a); a.click()
                    document.body.removeChild(a); URL.revokeObjectURL(url)
                  } catch { toast.error('Download failed') }
                }}
              >
                Download PDF
              </button>
              <button
                className="btn-ghost text-sm"
                onClick={async () => {
                  try {
                    const { data } = await api.get(`/predictions/qr/${result.id}`, { responseType: 'blob' })
                    window.open(URL.createObjectURL(data), '_blank')
                  } catch { toast.error('Failed to load QR code') }
                }}
              >
                View QR Code
              </button>
            </div>
          </div>
        )}
      </div>
    </Layout>
  )
}
