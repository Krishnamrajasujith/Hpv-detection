import { useRef, useState } from 'react'

interface Props {
  label: string
  accept?: string
  onFile: (file: File) => void
}

export default function FileDropzone({ label, accept = '.csv', onFile }: Props) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [fileName, setFileName] = useState('')
  const [dragging, setDragging] = useState(false)

  const handle = (file: File | undefined) => {
    if (!file) return
    setFileName(file.name)
    onFile(file)
  }

  return (
    <div
      className={`border-2 border-dashed rounded-xl p-6 text-center cursor-pointer transition-colors
        ${dragging ? 'border-accent bg-accent/5' : 'border-border hover:border-accent/60'}`}
      onClick={() => inputRef.current?.click()}
      onDragOver={(e) => { e.preventDefault(); setDragging(true) }}
      onDragLeave={() => setDragging(false)}
      onDrop={(e) => { e.preventDefault(); setDragging(false); handle(e.dataTransfer.files[0]) }}
    >
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        className="hidden"
        onClick={(e) => { (e.target as HTMLInputElement).value = '' }}
        onChange={(e) => handle(e.target.files?.[0])}
      />
      {fileName ? (
        <div className="text-teal font-medium text-sm">✓ {fileName}</div>
      ) : (
        <>
          <div className="text-3xl mb-2">↑</div>
          <div className="text-light text-sm">{label}</div>
          <div className="text-muted text-xs mt-1">drag & drop or click to browse</div>
        </>
      )}
    </div>
  )
}
