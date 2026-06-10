FROM python:3.11-slim

WORKDIR /app

# Build context is repo root, so requirements.txt lives under backend/
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN mkdir -p backend/static/heatmaps backend/static/qr backend/static/reports

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
