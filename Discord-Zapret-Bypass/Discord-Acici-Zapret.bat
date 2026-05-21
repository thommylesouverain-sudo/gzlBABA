@echo off
chcp 65001 >nul
title Discord Erisim Araci (Zapret Modu)
color 0B

set "SCRIPT=%~f0"
set "BATDIR=%~dp0"
if "%BATDIR:~-1%"=="\" set "BATDIR=%BATDIR:~0,-1%"

:: Admin kontrolu
net session >nul 2>&1
if %errorLevel% equ 0 goto IS_ADMIN

echo.
echo  Yonetici izni gerekiyor, yeniden baslatiliyor...
powershell -NoProfile -Command "Start-Process -FilePath '%SCRIPT%' -Verb RunAs"
exit /b

:IS_ADMIN
cls
echo.
echo  ==========================================================
echo            DISCORD ERISIM ARACI (ZAPRET MODU)
echo  ==========================================================
echo.
echo   Bu mod Turkcell Superonline altyapisi icin ozel olarak
echo   tasarlanmistir. GoodbyeDPI calismadigi durumlarda bunu
echo   kullanabilirsiniz.
echo.
echo   [1]  Bypass Mod 1'i Baslat (Standart)
echo   [2]  Bypass Mod 2'i Baslat (Superonline Ozel)
echo   [3]  Bypass'i Kapat (Servisi durdur)
echo   [4]  DNS Ayarlarini Guncelle (Google DNS 8.8.8.8)
echo   [5]  Cikis
echo.
echo  ----------------------------------------------------------
set /p secim="  Seciminiz (1-5): "

if "%secim%"=="1" goto RUN_MOD1
if "%secim%"=="2" goto RUN_MOD2
if "%secim%"=="3" goto STOP_BYPASS
if "%secim%"=="4" goto SET_DNS
if "%secim%"=="5" exit /b
goto IS_ADMIN

:RUN_MOD1
call :KILL_PREVIOUS
echo.
echo  Bypass Mod 1 baslatiliyor...
start "Zapret-Bypass" /min "%BATDIR%\winws.exe" --wf-tcp=80,443 --filter-tcp=80,443 --hostlist="%BATDIR%\discord-list.txt" --dpi-desync=fake --dpi-desync-fooling=md5sig
goto START_DISCORD

:RUN_MOD2
call :KILL_PREVIOUS
echo.
echo  Bypass Mod 2 (Superonline Ozel) baslatiliyor...
start "Zapret-Bypass" /min "%BATDIR%\winws.exe" --wf-tcp=80,443 --filter-tcp=80,443 --hostlist="%BATDIR%\discord-list.txt" --dpi-desync=fake,multidisorder --dpi-desync-split-pos=midsld --dpi-desync-repeats=6 --dpi-desync-fooling=badseq,md5sig
goto START_DISCORD

:START_DISCORD
echo  DNS onbellegi temizleniyor...
ipconfig /flushdns >nul
echo.
echo  [OK] Bypass arka planda calisiyor.
echo.
echo  Discord baslatiliyor...
:: Discord kapatma/acma kismi
taskkill /f /im Discord.exe >nul 2>&1
timeout /t 2 /nobreak >nul
set "DISCORD_LAUNCHED=0"
if exist "%localappdata%\Discord\Update.exe" (
    start "" "%localappdata%\Discord\Update.exe" --processStart Discord.exe
    set "DISCORD_LAUNCHED=1"
)
if exist "%localappdata%\DiscordCanary\Update.exe" (
    start "" "%localappdata%\DiscordCanary\Update.exe" --processStart Discord.exe
    set "DISCORD_LAUNCHED=1"
)
if "%DISCORD_LAUNCHED%"=="0" (
    echo  [UYARI] Discord otomatik baslatilamadi, lutfen elinizle acin.
) else (
    echo  [OK] Discord baslatildi!
)
echo.
pause
goto IS_ADMIN

:STOP_BYPASS
call :KILL_PREVIOUS
echo.
echo  [OK] Tum bypass servisleri kapatildi.
pause
goto IS_ADMIN

:SET_DNS
echo.
echo  Google DNS ayarlaniyor...
powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false } | Set-DnsClientServerAddress -ServerAddresses ('8.8.8.8','8.8.4.4') -ErrorAction SilentlyContinue"
echo  DNS onbellegi temizleniyor...
ipconfig /flushdns >nul
echo  [OK] DNS Ayarlandi.
pause
goto IS_ADMIN

:KILL_PREVIOUS
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im winws2.exe >nul 2>&1
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
goto :EOF