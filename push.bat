@echo off
setlocal
chcp 65001 >nul

for /f "usebackq delims=" %%i in (`where git 2^>nul`) do set "GIT=%%i" & goto :gitok
for /f "usebackq delims=" %%i in (`dir /b /s "C:\Program Files\Git\bin\git.exe" 2^>nul`) do set "GIT=%%i" & goto :gitok
echo [ERROR] Git not found!
pause
exit /b 1

:gitok
cd /d "%~dp0"

echo Taking fresh files from Downloads (if newer)...
robocopy "%USERPROFILE%\Downloads" . players.json players.js /XO /NJH /NJS /NP /NFL /NDL >nul

echo Pushing site update to GitHub...
"%GIT%" add players.json players.js index.html
"%GIT%" commit -m "Update roster"
if errorlevel 1 (
  echo.
  echo [OK] Nothing to update - files are already the same.
  pause
  exit /b 0
)
"%GIT%" push
if errorlevel 1 (
  echo.
  echo [ERROR] Push failed - check internet / login!
  pause
  exit /b 1
)
echo.
echo [DONE] Updates sent! Site refreshes in ~1-2 min, mod picks it up in ~1 min.
pause
