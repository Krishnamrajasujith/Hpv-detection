# HPV DetectAI - Quick Setup Guide

## ⚡ Automated Setup (Easiest Way)

### Option 1: Double-Click Setup
Simply **double-click** `setup.bat` in the project root directory. This will automatically:
- ✓ Check for Python, Node.js, and Docker
- ✓ Create Python virtual environments
- ✓ Install all dependencies
- ✓ Create configuration files (.env)
- ✓ Generate startup scripts

### Option 2: PowerShell Setup
Open PowerShell and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\setup-project.ps1
```

---

## 🚀 Running the Project

After setup completes, you'll have these startup scripts:

### Start Everything at Once
```
start-all.bat
```
This opens 3 separate windows:
- Backend (FastAPI)
- Frontend (React/Vite)
- PostgreSQL (Docker)

### Start Individual Services

**Backend Only:**
```
start-backend.bat
```
Runs on: `http://localhost:8000`
API Docs: `http://localhost:8000/docs`

**Frontend Only:**
```
start-frontend.bat
```
Runs on: `http://localhost:5173`

**Database Only:**
```
start-database.bat
```
PostgreSQL on: `localhost:5432`

---

## 📋 Prerequisites (Auto-Checked)

Before running setup, ensure you have:

1. **Python 3.11+**
   - Download: https://www.python.org/downloads/
   - Add to PATH during installation ✓

2. **Node.js 18+**
   - Download: https://nodejs.org/
   - Add to PATH during installation ✓

3. **Docker (Optional but Recommended)**
   - Download: https://www.docker.com/products/docker-desktop/
   - For PostgreSQL database

---

## ⚙️ Configuration Files

After setup, update these files with your actual settings:

### backend/.env
```
DATABASE_URL=postgresql://postgres:password@localhost:5432/hpv_detect
FRONTEND_URL=http://localhost:5173
SECRET_KEY=your-secret-key-here
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### frontend/.env
```
VITE_API_URL=http://localhost:8000
```

---

## 🐳 Database Setup

### Option 1: Docker (Recommended)
```
start-database.bat
```
PostgreSQL will be available at:
- Host: `localhost`
- Port: `5432`
- Username: `postgres`
- Password: `password`

### Option 2: Local PostgreSQL Installation
- Install PostgreSQL 15+
- Create database: `hpv_detect`
- Update `DATABASE_URL` in backend/.env

---

## 📱 Mobile App Setup (Flutter)

If you need to set up the Flutter mobile app:

```powershell
cd app
flutter pub get
flutter run
```

Requires Flutter SDK: https://flutter.dev/docs/get-started/install

---

## 🔍 Troubleshooting

### "Python not found"
- Install Python 3.11+: https://www.python.org/downloads/
- Make sure to check "Add Python to PATH" during installation
- Restart terminal/PowerShell after installation

### "Node not found"
- Install Node.js: https://nodejs.org/
- Check "Automatically install necessary tools" during setup
- Restart terminal after installation

### "pip install fails"
- Ensure Python virtual environment is activated
- Try: `pip install --upgrade pip`
- Then retry: `pip install -r requirements.txt`

### "Port already in use"
- Backend (8000), Frontend (5173), Database (5432)
- Kill existing processes using these ports
- Or change ports in startup scripts

---

## 📁 Project Structure

```
d:\Desktop\sujiths\
├── backend/          # FastAPI server
├── frontend/         # React Vite app
├── app/              # Flutter mobile app
├── write-files/      # Utility scripts
├── setup.bat         # Quick setup launcher
└── setup-project.ps1 # PowerShell setup script
```

---

## 🎯 Access Points

Once everything is running:

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:5173 | React UI |
| Backend API | http://localhost:8000 | REST API |
| API Docs | http://localhost:8000/docs | Swagger Documentation |
| Database | localhost:5432 | PostgreSQL |

---

## ✅ Verification

After setup, verify everything works:

1. **Check Backend:**
   ```
   curl http://localhost:8000/
   ```
   Should return: `{"status": "ok", "service": "HPV DetectAI API v2"}`

2. **Check Frontend:**
   Open http://localhost:5173 in browser

3. **Check Database:**
   ```
   psql -h localhost -U postgres -d hpv_detect
   ```

---

## 💡 Tips

- Keep all 3 startup windows open while developing
- Use `Ctrl+C` to stop individual services
- Check startup window logs for errors
- Clear browser cache if frontend shows stale content (`Ctrl+Shift+Delete`)
- Backend auto-reloads on file changes (--reload flag)

---

## 📞 Support

For issues or questions, check:
- Backend logs: Look in backend startup window
- Frontend logs: Look in browser console (F12)
- API Documentation: http://localhost:8000/docs

---

**Happy Coding! 🚀**
