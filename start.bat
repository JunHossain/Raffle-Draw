@echo off
cd /d "%~dp0"
echo Raffle Draw running at http://localhost:8000  -  close this window to stop.
start "" /min cmd /c "timeout /t 2 >nul & start http://localhost:8000/index.html"
python -m http.server 8000 --bind 127.0.0.1
