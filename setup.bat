@echo off
REM HPV DetectAI - Quick Setup Script
REM Run this file to automatically set up the entire project

echo ================================================
echo HPV DetectAI - Automated Setup
echo ================================================
echo.

REM Get the directory where this script is located
cd /d "%~dp0"

REM Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: PowerShell not found
    echo Please ensure PowerShell is installed and in your PATH
    pause
    exit /b 1
)

REM Run the PowerShell setup script
echo Running setup script...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "setup-project.ps1"

if %errorlevel% neq 0 (
    echo.
    echo Setup failed! Check errors above.
    pause
    exit /b 1
)

echo.
echo Setup completed successfully!
echo.
pause
