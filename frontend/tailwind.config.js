/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        bg: '#070d1a',
        surface: '#0d1a2e',
        border: '#1e3a5f',
        accent: '#3d7fff',
        cyan: '#00c6ff',
        teal: '#0ee7b0',
        danger: '#ff4f6d',
        warn: '#ffb340',
        muted: '#5a7a9a',
        light: '#b0c4de',
      },
      fontFamily: {
        sans: ['"DM Sans"', 'sans-serif'],
        mono: ['"DM Mono"', 'monospace'],
      },
    },
  },
  plugins: [],
}
