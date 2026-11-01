@echo off
cd /d "%~dp0"
if not exist "participants.txt" (
  echo Could not find participants.txt next to start.bat.
  echo If you opened this from inside the .rar, extract the whole folder first, then run start.bat again.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
if errorlevel 1 pause
