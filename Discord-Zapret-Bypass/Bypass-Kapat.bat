@echo off
chcp 65001 >nul
title Discord Erisim Araci - Kapat
color 0C
net session >nul 2>&1
if %errorLevel% equ 0 goto IS_ADMIN
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b

:IS_ADMIN
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im winws2.exe >nul 2>&1
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
echo.
echo  ==========================================================
echo    Bypass basariyla kapatildi ve temizlendi.
echo  ==========================================================
echo.
pause