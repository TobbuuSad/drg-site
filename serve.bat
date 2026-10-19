@echo off
chcp 65001 >nul
echo ================================================
echo   DRG сайт - локальный хостинг
echo   Таблица:  http://localhost:8000/
echo   Для мода: http://localhost:8000/players.json
echo   (в config/drg-nametags.json укажите siteUrl выше)
echo   Ctrl+C - остановить
echo ================================================
where py >nul 2>nul
if %errorlevel%==0 (
  py -m http.server 8000
) else (
  python -m http.server 8000
)
pause
