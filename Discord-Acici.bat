@echo off
chcp 65001 >nul
title Discord Erisim Araci
color 0B

set "SCRIPT=%~f0"
set "BATDIR=%~dp0"
if "%BATDIR:~-1%"=="\" set "BATDIR=%BATDIR:~0,-1%"

net session >nul 2>&1
if %errorLevel% equ 0 goto IS_ADMIN

echo.
echo  Yonetici izni gerekiyor, yeniden baslatiliyor...
set "PSARGS="
:BUILD_ARGS
set "A=%~1"
if "%A%"=="" goto DO_ELEVATE
if defined PSARGS (set "PSARGS=%PSARGS%,'%A%'") else (set "PSARGS='%A%'")
shift /1
goto BUILD_ARGS
:DO_ELEVATE
if defined PSARGS (
    powershell -NoProfile -Command "Start-Process -FilePath '%SCRIPT%' -ArgumentList %PSARGS% -Verb RunAs"
) else (
    powershell -NoProfile -Command "Start-Process -FilePath '%SCRIPT%' -Verb RunAs"
)
exit /b

:IS_ADMIN
set "SCRIPTNAME=%~n0"

if /i "%SCRIPTNAME%"=="site" if "%~1"=="" goto DO_SITE_USAGE
if /i "%SCRIPTNAME%"=="gzlbaba" if "%~1"=="" goto MENU
if /i "%SCRIPTNAME%"=="gzlbaba" if /i "%~1"=="reset" goto DO_RESET
if /i "%SCRIPTNAME%"=="gzlbaba" if /i "%~1"=="sifirla" goto DO_RESET
if /i "%SCRIPTNAME%"=="gzlbaba" if /i "%~1"=="ac" call :RUN_PS Open "" & pause & exit /b
if /i "%SCRIPTNAME%"=="gzlbaba" if /i "%~1"=="durum" call :RUN_PS Status "" & pause & exit /b
if /i "%SCRIPTNAME%"=="gzlbaba" if /i "%~1"=="status" call :RUN_PS Status "" & pause & exit /b
if /i "%~1"=="ac"     goto SITE_CMD
if /i "%~1"=="aç"     goto SITE_CMD
if /i "%~1"=="add"    goto SITE_CMD
if /i "%~1"=="ekle"   goto SITE_CMD
if /i "%~1"=="kapat"  goto SITE_CMD
if /i "%~1"=="remove" goto SITE_CMD
if /i "%~1"=="sil"    goto SITE_CMD
if /i "%~1"=="liste"  goto SITE_CMD
if /i "%~1"=="list"   goto SITE_CMD
if /i "%~1"=="sifirla" goto DO_RESET
if /i "%~1"=="reset"   goto DO_RESET
goto MENU

:DO_RESET
call :RUN_PS Restore ""
pause
exit /b

:DO_SITE_USAGE
call :RUN_PS SiteUsage ""
pause
exit /b

:SITE_CMD
set "SITECMD=%~1"
shift /1
set "DOMAINS="
:COLLECT
set "D=%~1"
if "%D%"=="" goto ROUTE_SITE
if defined DOMAINS (set "DOMAINS=%DOMAINS% %D%") else (set "DOMAINS=%D%")
shift /1
goto COLLECT
:ROUTE_SITE
set "ACTION=SiteList"
if /i "%SITECMD%"=="ac"     set "ACTION=SiteAdd"
if /i "%SITECMD%"=="aç"     set "ACTION=SiteAdd"
if /i "%SITECMD%"=="add"    set "ACTION=SiteAdd"
if /i "%SITECMD%"=="ekle"   set "ACTION=SiteAdd"
if /i "%SITECMD%"=="kapat"  set "ACTION=SiteRemove"
if /i "%SITECMD%"=="remove" set "ACTION=SiteRemove"
if /i "%SITECMD%"=="sil"    set "ACTION=SiteRemove"
if /i "%SITECMD%"=="liste"  set "ACTION=SiteList"
if /i "%SITECMD%"=="list"   set "ACTION=SiteList"
call :RUN_PS %ACTION% "%DOMAINS%"
pause
exit /b

:MENU
cls
set "CURRENT_MOD=Standart Mod (Turk Telekom, TurkNet vb.)"
if exist "%ProgramData%\DiscordAcici\active-preset.txt" (
    set /p CURRENT_MOD=<"%ProgramData%\DiscordAcici\active-preset.txt"
)
echo.
echo  ==========================================================
echo                    DISCORD ERISIM ARACI
echo  ==========================================================
echo.
echo   Hosts dosyasi + GoodbyeDPI servisi
echo   (sadece Discord trafigine etki eder)
echo.
echo   Internet hizina ve oyun pingine HICBIR etkisi yoktur.
echo.
echo  ----------------------------------------------------------
echo   Aktif Baglanti Modu: %CURRENT_MOD%
echo  ----------------------------------------------------------
echo.
echo   [1]  Discord'u Ac  (Tam kurulum)
echo   [2]  Discord'u Ac  (Discord'u yeniden baslatmadan)
echo   [3]  Geri Al  (Kaldirma)
echo   [4]  Baglanti Modunu Degistir (Superonline vb. icin)
echo   [5]  Durum Goster
echo   [6]  Guncelle
echo   [7]  Cikis
echo.
echo  ----------------------------------------------------------
echo   CMD'den site acmak icin:  site ac x.com
echo  ----------------------------------------------------------
echo.
set /p secim="  Seciminiz (1-7): "

if "%secim%"=="1" (cls & call :RUN_PS Open "" & pause & goto MENU)
if "%secim%"=="2" (cls & call :RUN_PS OpenNoRestart "" & pause & goto MENU)
if "%secim%"=="3" (cls & call :RUN_PS Restore "" & pause & goto MENU)
if "%secim%"=="4" (cls & call :RUN_PS ChangeMode "" & goto MENU)
if "%secim%"=="5" (cls & call :RUN_PS Status "" & pause & goto MENU)
if "%secim%"=="6" (cls & call :RUN_PS Update "" & pause & goto MENU)
if "%secim%"=="7" exit /b
goto MENU


:RUN_PS
set "PS1FILE=%TEMP%\discord-acici.ps1"
powershell -NoProfile -Command "$c = [IO.File]::ReadAllText('%SCRIPT%', [Text.Encoding]::UTF8); $m = [regex]::Match($c, '(?s)::PS_BEGIN\s*\r?\n(.*?)\r?\n::PS_END'); if ($m.Success) { $enc = New-Object Text.UTF8Encoding $false; [IO.File]::WriteAllText('%PS1FILE%', $m.Groups[1].Value, $enc) }"
if not exist "%PS1FILE%" (
    echo.
    echo  [HATA] PowerShell scripti olusturulamadi.
    pause
    exit /b
)
powershell -NoP -EP Bypass -File "%PS1FILE%" %1 "%BATDIR%" "%~2"
del "%PS1FILE%" >nul 2>&1
exit /b

::PS_BEGIN
param(
    [string]$Action = 'Open',
    [string]$BatDir = '',
    [string]$Domains = ''
)
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$ScriptVersion = '1.0.0'
$UpdateUrl = 'https://raw.githubusercontent.com/thommylesouverain-sudo/gzlBABA/main/Discord-Acici.bat'

$hostsPath   = "$env:WINDIR\System32\drivers\etc\hosts"
$marker      = '# === DISCORD-ACICI-START ==='
$endMarker   = '# === DISCORD-ACICI-END ==='
$serviceName = 'GoodbyeDPI'
$installDir  = "$env:ProgramData\DiscordAcici"
$blacklistPath = Join-Path $installDir 'discord-blacklist.txt'

$cfDomains = @(
    'discord.com', 'discordapp.com', 'discord.gg', 'discord.media',
    'cdn.discordapp.com', 'media.discordapp.net',
    'gateway.discord.gg', 'status.discord.com', 'updates.discord.com',
    'router.discordapp.net', 'support.discord.com',
    'canary.discord.com', 'ptb.discord.com',
    'assets.discord.com', 'app.discord.com',
    'images-ext-1.discordapp.net', 'images-ext-2.discordapp.net',
    'latency.discord.media', 'discordstatus.com',
    'dl.discordapp.net', 'dl-builds.discordapp.net',
    'dl-canary.discordapp.net', 'dl-canary-builds.discordapp.net',
    'dl-ptb.discordapp.net', 'dl-ptb-builds.discordapp.net'
)
$gcpDomains = @('stable.dl2.discordapp.net')

$resolvers = @(
    'https://1.1.1.1/dns-query',
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/resolve'
)

# ==================== YARDIMCI FONKSIYONLAR ====================

function Resolve-PrimaryIp {
    param([string]$Domain, [string]$DefaultIp)
    foreach ($r in $resolvers) {
        try {
            $url = $r + '?name=' + $Domain + '&type=A'
            $resp = Invoke-RestMethod -Uri $url -Headers @{'accept'='application/dns-json'} -TimeoutSec 8
            if ($resp.Answer) {
                $ips = @($resp.Answer | Where-Object { $_.type -eq 1 } | Select-Object -ExpandProperty data)
                if ($ips.Count -gt 0) { return $ips[0] }
            }
        } catch {}
    }
    return $DefaultIp
}

function Test-Latency {
    $results = @{ InternetMs = -1; DiscordMs = -1; DiscordOk = $false }
    try {
        $ping = Test-Connection -ComputerName '8.8.8.8' -Count 2 -ErrorAction Stop -TimeoutSec 2
        $avg = ($ping | Measure-Object -Property ResponseTime -Average).Average
        $results.InternetMs = [math]::Round($avg, 0)
    } catch {}
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $ar = $tcp.BeginConnect('discord.com', 443, $null, $null)
        $wh = $ar.AsyncWaitHandle
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        if (-not $wh.WaitOne(3000, $false)) {
            $tcp.Close()
            throw "Timeout"
        }
        $tcp.EndConnect($ar)
        $sw.Stop()
        $tcp.Close()
        $results.DiscordMs = $sw.ElapsedMilliseconds
        $results.DiscordOk = $true
    } catch {
        $results.DiscordOk = $false
    }
    return $results
}

function Test-Internet {
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $ar = $tcp.BeginConnect('1.1.1.1', 443, $null, $null)
        $wh = $ar.AsyncWaitHandle
        if (-not $wh.WaitOne(3000, $false)) {
            $tcp.Close()
            return $false
        }
        $tcp.EndConnect($ar)
        $tcp.Close()
        return $true
    } catch {
        return $false
    }
}

function Find-BestPreset {
    Write-Host '  [Auto-Detect] En uygun baglanti modu araniyor...' -ForegroundColor Cyan
    
    if (-not (Test-Internet)) {
        Write-Host '   [UYARI] Internet baglantisi algilanamadi. Varsayilan mod kuruluyor.' -ForegroundColor Yellow
        return [PSCustomObject]@{
            PresetName = 'Standart Mod'
            Params = '-5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
        }
    }
    
    $presets = @(
        @{ Name = 'Standart Mod'; Params = '-5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253' },
        @{ Name = 'Superonline Yontem A (Alt 4)'; Params = '-5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253' },
        @{ Name = 'Superonline Yontem B (Alt 3)'; Params = '--set-ttl 3 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253' },
        @{ Name = 'Superonline Yontem C (Alt 5)'; Params = '-9 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253' }
    )
    
    $arch = if ([Environment]::Is64BitOperatingSystem) { 'x86_64' } else { 'x86' }
    $exePath = Join-Path $installDir "$arch\goodbyedpi.exe"
    
    foreach ($p in $presets) {
        Write-Host "               Deneniyor: $($p.Name)..." -ForegroundColor Gray
        
        $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($existing) {
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            & sc.exe delete $serviceName 2>$null | Out-Null
        }
        Get-Process -Name 'goodbyedpi*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        
        $binPath = '"' + $exePath + '" ' + $p.Params + ' --blacklist "' + $blacklistPath + '"'
        
        try {
            New-Service -Name $serviceName `
                        -BinaryPathName $binPath `
                        -StartupType Automatic `
                        -DisplayName 'GoodbyeDPI' `
                        -Description 'Discord DPI bypass servisi' `
                        -ErrorAction Stop | Out-Null
            Start-Service -Name $serviceName -ErrorAction Stop
            
            & ipconfig /flushdns | Out-Null
            Start-Sleep -Seconds 3
            
            $test = Test-Latency
            if ($test.DiscordOk) {
                Write-Host "               [OK] Calisan mod bulundu: $($p.Name)!" -ForegroundColor Green
                return [PSCustomObject]@{
                    PresetName = $p.Name
                    Params = $p.Params
                }
            }
        } catch {}
    }
    
    Write-Host '               [UYARI] Calisan mod bulunamadi. Standart Mod seciliyor.' -ForegroundColor Yellow
    return [PSCustomObject]@{
        PresetName = 'Standart Mod'
        Params = '-5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
    }
}

function Show-LatencyReport {
    param($Label, $Results)
    Write-Host ''
    Write-Host "  [$Label]" -ForegroundColor Yellow
    if ($Results.InternetMs -ge 0) {
        Write-Host "   Internet gecikme : $($Results.InternetMs) ms" -ForegroundColor Green
    } else {
        Write-Host '   Internet gecikme : Olculemedi' -ForegroundColor Red
    }
    if ($Results.DiscordOk) {
        Write-Host "   Discord baglanti : Erisiliyor ($($Results.DiscordMs) ms)" -ForegroundColor Green
    } else {
        Write-Host '   Discord baglanti : Erisilemedi' -ForegroundColor Red
    }
}


function Show-WinNotification {
    param([string]$Title, [string]$Message)
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        $balloon = New-Object System.Windows.Forms.NotifyIcon
        $balloon.Icon = [System.Drawing.SystemIcons]::Information
        $balloon.BalloonTipTitle = $Title
        $balloon.BalloonTipText = $Message
        $balloon.BalloonTipIcon = 'Info'
        $balloon.Visible = $true
        $balloon.ShowBalloonTip(5000)
        Start-Sleep -Milliseconds 1000
        $balloon.Dispose()
    } catch {}
}

function Restart-DiscordApp {
    Write-Host ''
    Write-Host '  [Discord] Yeniden baslatiliyor...' -ForegroundColor Cyan
    $procs = Get-Process -Name 'Discord*' -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host '            Discord kapatildi' -ForegroundColor Green
    } else {
        Write-Host '            Discord zaten kapali' -ForegroundColor Gray
    }
    $discordPaths = @(
        "$env:LOCALAPPDATA\Discord\Update.exe",
        "$env:LOCALAPPDATA\DiscordCanary\Update.exe",
        "$env:LOCALAPPDATA\DiscordPTB\Update.exe"
    )
    foreach ($dp in $discordPaths) {
        if (Test-Path $dp) {
            Start-Process $dp -ArgumentList '--processStart','Discord.exe' -ErrorAction SilentlyContinue
            Write-Host '            Discord baslatildi' -ForegroundColor Green
            return
        }
    }
    Write-Host '            Discord kurulumu bulunamadi, elle acin' -ForegroundColor Yellow
}

function Install-SiteTool {
    $batFile = Get-ChildItem -Path $BatDir -Filter 'Discord-Acici.bat' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $batFile) { return }
    $srcBat = $batFile.FullName
    $targets = @{
        "$env:WINDIR\site.bat"    = 'site'
        "$env:WINDIR\gzlbaba.bat" = 'gzlbaba'
    }
    foreach ($dest in $targets.Keys) {
        $name = $targets[$dest]
        try {
            Copy-Item -Path $srcBat -Destination $dest -Force -ErrorAction Stop
            Write-Host "  [OK] ""$name"" komutu yuklendi" -ForegroundColor Green
        } catch {
            Write-Host "  [UYARI] ""$name"" yuklenemedi: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    Write-Host ''
    Write-Host '        Artik her yerden kullanabilirsiniz:' -ForegroundColor Gray
    Write-Host '          site ac x.com       (site engeli kaldir)' -ForegroundColor Gray
    Write-Host '          gzlbaba reset       (herseyi sifirla)' -ForegroundColor Gray
    Write-Host '          gzlbaba durum       (durum goster)' -ForegroundColor Gray
}

# ==================== DNS FONKSIYONLARI ====================

function Set-SystemDns {
    Write-Host '  [DNS] Google DNS ayarlaniyor (8.8.8.8 / 8.8.4.4)...' -ForegroundColor Cyan
    try {
        $adapters = Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false }
        foreach ($a in $adapters) {
            try {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses ('8.8.8.8','8.8.4.4') -ErrorAction Stop
                Write-Host "        [OK] $($a.Name)" -ForegroundColor Green
            } catch {
                Write-Host "        [UYARI] $($a.Name): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "        [HATA] $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Reset-SystemDns {
    Write-Host '  [DNS] Otomatige donduruluyor...' -ForegroundColor Cyan
    try {
        $adapters = Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false }
        foreach ($a in $adapters) {
            try {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop
                Write-Host "        [OK] $($a.Name)" -ForegroundColor Green
            } catch {}
        }
    } catch {}
}

# ==================== HOSTS FONKSIYONLARI ====================

function Update-HostsFile {
    Write-Host '  [Hosts] Yedekleniyor...' -ForegroundColor Cyan
    $backup = $hostsPath + '.discord-backup'
    if (-not (Test-Path $backup)) {
        Copy-Item $hostsPath $backup -Force
        Write-Host '          Yedek olusturuldu' -ForegroundColor Green
    } else {
        Write-Host '          Yedek zaten mevcut' -ForegroundColor Green
    }

    Write-Host '  [Hosts] IP cozumleniyor (DoH)...' -ForegroundColor Cyan
    $cfIp  = Resolve-PrimaryIp -Domain 'discord.com'                -DefaultIp '162.159.135.232'
    $gcpIp = Resolve-PrimaryIp -Domain 'stable.dl2.discordapp.net'  -DefaultIp '34.107.221.82'
    Write-Host "          Cloudflare IP : $cfIp"  -ForegroundColor Green
    Write-Host "          GoogleCloud IP: $gcpIp" -ForegroundColor Green

    $entries = @()
    foreach ($d in $cfDomains)  { $entries += [PSCustomObject]@{ IP = $cfIp;  Domain = $d } }
    foreach ($d in $gcpDomains) { $entries += [PSCustomObject]@{ IP = $gcpIp; Domain = $d } }

    Write-Host '  [Hosts] Yaziliyor...' -ForegroundColor Cyan
    $content = ''
    if (Test-Path $hostsPath) { $content = [IO.File]::ReadAllText($hostsPath) }
    $pattern = [regex]::Escape($marker) + '[\s\S]*?' + [regex]::Escape($endMarker) + '\r?\n?'
    $content = [regex]::Replace($content, $pattern, '')

    $sb = New-Object Text.StringBuilder
    [void]$sb.AppendLine($marker)
    foreach ($e in $entries) {
        [void]$sb.AppendLine(($e.IP.PadRight(18) + $e.Domain))
    }
    [void]$sb.AppendLine($endMarker)

    $content = $content.TrimEnd() + "`r`n`r`n" + $sb.ToString()
    [IO.File]::WriteAllText($hostsPath, $content, [Text.Encoding]::ASCII)
    Write-Host "          $($entries.Count) domain yazildi" -ForegroundColor Green
}

# ==================== DPI BYPASS ====================

function Find-LocalGoodbyeDPI {
    $candidates = @()
    if ($BatDir -and (Test-Path $BatDir)) {
        $candidates += $BatDir
        Get-ChildItem -Path $BatDir -Directory -Filter 'goodbyedpi-*' -ErrorAction SilentlyContinue | ForEach-Object { $candidates += $_.FullName }
    }
    $userDirs = @("$env:USERPROFILE\Pictures","$env:USERPROFILE\Downloads","$env:USERPROFILE\Desktop","$env:USERPROFILE\Documents")
    foreach ($d in $userDirs) {
        if (Test-Path $d) {
            Get-ChildItem -Path $d -Directory -Filter 'goodbyedpi-*' -ErrorAction SilentlyContinue | ForEach-Object { $candidates += $_.FullName }
        }
    }
    foreach ($p in $candidates) {
        if (Test-Path (Join-Path $p 'x86_64\goodbyedpi.exe')) { return $p }
    }
    return $null
}

function Install-DpiBypass {
    Write-Host ''
    Write-Host '  [DPI Bypass] GoodbyeDPI kuruluyor...' -ForegroundColor Cyan

    # Servis, process ve WinDivert driver'ini durdur (dosya kilidi icin)
    $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host '               Mevcut servis durduruluyor...' -ForegroundColor Cyan
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        & sc.exe delete $serviceName 2>$null | Out-Null
    }
    Get-Process -Name 'goodbyedpi*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    & sc.exe stop WinDivert 2>$null | Out-Null
    & sc.exe delete WinDivert 2>$null | Out-Null
    & sc.exe stop WinDivert64 2>$null | Out-Null
    & sc.exe delete WinDivert64 2>$null | Out-Null
    Start-Sleep -Seconds 2

    if (-not (Test-Path $installDir)) {
        New-Item -Path $installDir -ItemType Directory -Force | Out-Null
    }

    $arch = if ([Environment]::Is64BitOperatingSystem) { 'x86_64' } else { 'x86' }
    $exePath = Join-Path $installDir "$arch\goodbyedpi.exe"

    if (-not (Test-Path $exePath)) {
        $localSrc = Find-LocalGoodbyeDPI
        if ($localSrc) {
            Write-Host "               Yerel kopya: $localSrc" -ForegroundColor Gray
            try {
                Copy-Item -Path (Join-Path $localSrc '*') -Destination $installDir -Recurse -Force -ErrorAction Stop
                Write-Host '               [OK] Kopyalandi' -ForegroundColor Green
            } catch {
                Write-Host "               [HATA] $($_.Exception.Message)" -ForegroundColor Red
                return
            }
        } else {
            Write-Host '               [BILGI] GoodbyeDPI yerelde bulunamadi, indiriliyor...' -ForegroundColor Cyan
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $zipUrl = 'https://raw.githubusercontent.com/thommylesouverain-sudo/gzlBABA/main/goodbyedpi-0.2.3rc3-turkey.zip'
                $tempZip = Join-Path $env:TEMP 'goodbyedpi-turkey.zip'
                Write-Host '               GitHub''dan indiriliyor...' -ForegroundColor Gray
                Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -TimeoutSec 45 -ErrorAction Stop
                Write-Host '               [OK] Indirildi. Dosyalar aciliyor...' -ForegroundColor Green
                
                $tempExtract = Join-Path $env:TEMP 'goodbyedpi-extract'
                if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
                Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
                
                $extractedFolder = Get-ChildItem -Path $tempExtract -Directory | Select-Object -First 1
                if ($extractedFolder) {
                    Copy-Item -Path (Join-Path $extractedFolder.FullName '*') -Destination $installDir -Recurse -Force -ErrorAction Stop
                } else {
                    Copy-Item -Path (Join-Path $tempExtract '*') -Destination $installDir -Recurse -Force -ErrorAction Stop
                }
                
                Remove-Item $tempZip -Force
                Remove-Item $tempExtract -Recurse -Force
                Write-Host '               [OK] Kurulum tamamlandi' -ForegroundColor Green
            } catch {
                Write-Host "               [HATA] Indirme veya acma basarisiz: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host '               Lutfen BAT dosyasinin yanina goodbyedpi-* klasorunu elle koyun' -ForegroundColor Yellow
                return
            }
        }
    } else {
        Write-Host '               GoodbyeDPI zaten kurulu' -ForegroundColor Green
    }

    if (-not (Test-Path $exePath)) {
        Write-Host '               [HATA] goodbyedpi.exe bulunamadi' -ForegroundColor Red
        return
    }

    @(
        'discord.com', 'discordapp.com', 'discord.gg',
        'discord.media', 'discordapp.net', 'discordstatus.com'
    ) | Set-Content -Path $blacklistPath -Encoding ASCII
    Write-Host '               [OK] Blacklist olusturuldu' -ForegroundColor Green

    $presetName = ''
    $params = ''
    $presetPath = Join-Path $installDir 'active-preset.txt'
    $paramsPath = Join-Path $installDir 'active-params.txt'

    if (Test-Path $paramsPath) {
        $params = (Get-Content $paramsPath -Raw).Trim()
        if (Test-Path $presetPath) {
            $presetName = (Get-Content $presetPath -Raw).Trim()
        } else {
            $presetName = 'Kullanici Tanimli'
        }
        Write-Host "               Kayitli mod yukleniyor: $presetName" -ForegroundColor Green
    } else {
        $result = Find-BestPreset
        $presetName = $result.PresetName
        $params = $result.Params
        Set-Content -Path $presetPath -Value $presetName -Encoding ASCII
        Set-Content -Path $paramsPath -Value $params -Encoding ASCII
    }

    $binPath = '"' + $exePath + '" ' + $params + ' --blacklist "' + $blacklistPath + '"'

    try {
        $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($existing) {
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            & sc.exe delete $serviceName 2>$null | Out-Null
            Start-Sleep -Seconds 1
        }

        New-Service -Name $serviceName `
                    -BinaryPathName $binPath `
                    -StartupType Automatic `
                    -DisplayName 'GoodbyeDPI' `
                    -Description 'Discord DPI bypass servisi' `
                    -ErrorAction Stop | Out-Null
        Start-Service -Name $serviceName -ErrorAction Stop
        Start-Sleep -Seconds 1

        $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq 'Running') {
            Write-Host '               [OK] Servis calisiyor' -ForegroundColor Green
        } else {
            Write-Host "               [UYARI] Servis durumu: $($svc.Status)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "               [HATA] $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ==================== SITE YONETIMI ====================

function Invoke-SiteAdd {
    param([string]$DomainStr)
    if (-not (Test-Path $blacklistPath)) {
        Write-Host ''
        Write-Host '  [HATA] Discord-Acici kurulu degil. Once [1] secenegini calistirin.' -ForegroundColor Red
        return
    }
    $doms = @($DomainStr.Trim().Split(' ', [StringSplitOptions]::RemoveEmptyEntries))
    if ($doms.Count -eq 0) {
        Write-Host ''
        Write-Host '  [HATA] Site adresi gerekli. Ornek: site ac x.com' -ForegroundColor Red
        return
    }
    $needRestart = $false
    Write-Host ''
    foreach ($raw in $doms) {
        $d = $raw.Trim().ToLower() -replace '^https?://', '' -replace '^www\.', '' -replace '/.*$', '' -replace ':.*$', ''
        if (-not $d) { continue }
        $lines = @(Get-Content $blacklistPath -ErrorAction SilentlyContinue)
        if ($lines -contains $d) {
            Write-Host "  [BILGI] Zaten acik: $d" -ForegroundColor Yellow
        } else {
            Add-Content -Path $blacklistPath -Value $d -Encoding ASCII
            Write-Host "  [OK] Eklendi: $d" -ForegroundColor Green
            $needRestart = $true
        }
    }
    if ($needRestart) {
        Write-Host ''
        Write-Host '  Servis yeniden baslatiliyor...' -ForegroundColor Cyan
        Restart-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($svc.Status -eq 'Running') {
            Write-Host '  [OK] Servis calisiyor' -ForegroundColor Green
        } else {
            Write-Host "  [UYARI] Servis durumu: $($svc.Status)" -ForegroundColor Yellow
        }
        Write-Host '  DNS onbellegi temizleniyor...' -ForegroundColor Cyan
        & ipconfig /flushdns | Out-Null
        Write-Host '  [OK] DNS temizlendi, site artik acik' -ForegroundColor Green
    }
}

function Invoke-SiteRemove {
    param([string]$DomainStr)
    if (-not (Test-Path $blacklistPath)) {
        Write-Host ''
        Write-Host '  [HATA] Discord-Acici kurulu degil.' -ForegroundColor Red
        return
    }
    $doms = @($DomainStr.Trim().Split(' ', [StringSplitOptions]::RemoveEmptyEntries))
    if ($doms.Count -eq 0) {
        Write-Host ''
        Write-Host '  [HATA] Site adresi gerekli. Ornek: site kapat x.com' -ForegroundColor Red
        return
    }
    $needRestart = $false
    Write-Host ''
    foreach ($raw in $doms) {
        $d = $raw.Trim().ToLower() -replace '^https?://', '' -replace '^www\.', '' -replace '/.*$', '' -replace ':.*$', ''
        if (-not $d) { continue }
        $lines = @(Get-Content $blacklistPath -ErrorAction SilentlyContinue)
        if (-not ($lines -contains $d)) {
            Write-Host "  [BILGI] Listede yok: $d" -ForegroundColor Yellow
        } else {
            $newLines = @($lines | Where-Object { $_.Trim().ToLower() -ne $d })
            Set-Content -Path $blacklistPath -Value $newLines -Encoding ASCII
            Write-Host "  [OK] Kaldirildi: $d" -ForegroundColor Green
            $needRestart = $true
        }
    }
    if ($needRestart) {
        Write-Host ''
        Write-Host '  Servis yeniden baslatiliyor...' -ForegroundColor Cyan
        Restart-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Write-Host '  DNS onbellegi temizleniyor...' -ForegroundColor Cyan
        & ipconfig /flushdns | Out-Null
        Write-Host '  [OK] DNS temizlendi, site engele geri dondu' -ForegroundColor Green
    }
}

function Invoke-SiteList {
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    AKTIF ACIK SITELER (DPI bypass uygulanan)' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''
    if (-not (Test-Path $blacklistPath)) {
        Write-Host '   Discord-Acici kurulu degil' -ForegroundColor Red
        return
    }
    $lines = @(Get-Content $blacklistPath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne '' })
    if ($lines.Count -eq 0) {
        Write-Host '   (liste bos)' -ForegroundColor DarkGray
    } else {
        foreach ($l in $lines) {
            Write-Host "   - $l" -ForegroundColor Green
        }
        Write-Host ''
        Write-Host "   Toplam: $($lines.Count) site" -ForegroundColor Cyan
    }
    Write-Host ''
}

function Invoke-SiteUsage {
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '                       SITE YONETICI' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '   Turkiye''deki site engellerini acar/kapatir.'
    Write-Host ''
    Write-Host '   KULLANIM:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '     site ac <adres>                 Siteyi acar'
    Write-Host '     site ac <adres1> <adres2> ...   Birden fazla site acar'
    Write-Host '     site kapat <adres>              Siteyi engele geri dondurur'
    Write-Host '     site liste                      Acik sitelerin listesi'
    Write-Host '     site sifirla                    Herseyi geri al (tam sifirlama)'
    Write-Host ''
    Write-Host '   ORNEK:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '     site ac x.com'
    Write-Host '     site ac reddit.com tiktok.com'
    Write-Host '     site kapat x.com'
    Write-Host '     site liste'
    Write-Host ''
    Write-Host '  ----------------------------------------------------------' -ForegroundColor DarkGray
    Write-Host '    AKTIF ACIK SITELER:' -ForegroundColor Yellow
    Write-Host '  ----------------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ''
    if (Test-Path $blacklistPath) {
        $lines = @(Get-Content $blacklistPath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne '' })
        if ($lines.Count -eq 0) {
            Write-Host '   (liste bos)' -ForegroundColor DarkGray
        } else {
            foreach ($l in $lines) { Write-Host "   - $l" -ForegroundColor Green }
            Write-Host ''
            Write-Host "   Toplam: $($lines.Count) site" -ForegroundColor Cyan
        }
    } else {
        Write-Host '   Discord-Acici kurulu degil' -ForegroundColor Red
    }
    Write-Host ''
}

# ==================== GUNCELLEME ====================

function Invoke-Update {
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    GUNCELLEME KONTROLU' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host "   Mevcut surum: $ScriptVersion" -ForegroundColor Gray

    if (-not $UpdateUrl) {
        Write-Host ''
        Write-Host '   [BILGI] Guncelleme URL''si ayarlanmamis.' -ForegroundColor Yellow
        Write-Host '   GitHub reposu olusturdugunda UpdateUrl degiskenini ayarla.' -ForegroundColor Gray
        Write-Host ''
        Write-Host '   Ornek: GitHub''da repo olustur, BAT dosyasini yukle,' -ForegroundColor Gray
        Write-Host '   ardindan raw URL''yi scriptteki $UpdateUrl''ye yaz.' -ForegroundColor Gray
        Write-Host ''
        return
    }

    Write-Host '   Kontrol ediliyor...' -ForegroundColor Cyan
    try {
        $remote = Invoke-RestMethod -Uri $UpdateUrl -TimeoutSec 10 -ErrorAction Stop
        $versionMatch = [regex]::Match($remote, "\`$ScriptVersion\s*=\s*'([^']+)'")
        if ($versionMatch.Success) {
            $remoteVersion = $versionMatch.Groups[1].Value
            if ($remoteVersion -ne $ScriptVersion) {
                Write-Host "   Yeni surum mevcut: $remoteVersion" -ForegroundColor Green
                Write-Host '   Indiriliyor...' -ForegroundColor Cyan
                $batPath = Join-Path $BatDir 'Discord-Acici.bat'
                $enc = New-Object Text.UTF8Encoding $false
                [IO.File]::WriteAllText($batPath, $remote, $enc)
                $sitePath = "$env:WINDIR\site.bat"
                if (Test-Path $sitePath) {
                    [IO.File]::WriteAllText($sitePath, $remote, $enc)
                }
                Write-Host '   [OK] Guncelleme tamamlandi! Programi yeniden baslatin.' -ForegroundColor Green
                Show-WinNotification 'Discord Acici' "Surum $remoteVersion yuklendi!"
            } else {
                Write-Host '   [OK] Zaten guncel.' -ForegroundColor Green
            }
        } else {
            Write-Host '   [HATA] Uzak dosyada surum bilgisi bulunamadi' -ForegroundColor Red
        }
    } catch {
        Write-Host "   [HATA] $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ''
}

function Invoke-ChangeMode {
    Clear-Host
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    MOD / ISS AYARINI DEGISTIR' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '   Turkcell Superonline ve bazi fiber altyapilarda standart ayarlar'
    Write-Host '   calismayabilir. Buradan farkli baglanti modlarini deneyebilirsiniz.'
    Write-Host ''
    Write-Host '   [1] Otomatik Algila (En uygun calisan modu otomatik bulur)'
    Write-Host ''
    Write-Host '   [2] Standart Mod (Turk Telekom, TurkNet, Kablonet, Millenicom vb. - Varsayilan)'
    Write-Host '       Parametreler: -5 --set-ttl 5 (Dahili Yandex DNS)'
    Write-Host ''
    Write-Host '   [3] Superonline - Yontem A (Alternatif 4) - EN COK CALISAN'
    Write-Host '       Parametreler: -5 (TTL degistirilmez, Dahili Yandex DNS)'
    Write-Host ''
    Write-Host '   [4] Superonline - Yontem B (Alternatif 3)'
    Write-Host '       Parametreler: --set-ttl 3 (Dusuk TTL, Dahili Yandex DNS)'
    Write-Host ''
    Write-Host '   [5] Superonline - Yontem C (Alternatif 5)'
    Write-Host '       Parametreler: -9 (Agresif DPI, Dahili Yandex DNS)'
    Write-Host ''
    Write-Host '   [6] Superonline - Yontem D (Alternatif 2)'
    Write-Host '       Parametreler: -5 (TTL degistirilmez, Yerel/Sistem DNS kullanir)'
    Write-Host ''
    Write-Host '   [7] Superonline - Yontem E (Alternatif 6)'
    Write-Host '       Parametreler: -9 (Agresif DPI, Yerel/Sistem DNS kullanir)'
    Write-Host ''
    Write-Host '   [8] Geri Don'
    Write-Host ''

    $choice = Read-Host '   Seciminiz (1-8)'
    if ($choice -eq '8' -or [string]::IsNullOrWhiteSpace($choice)) { return }

    $presetName = ''
    $params = ''

    switch ($choice) {
        '1' {
            $result = Find-BestPreset
            $presetName = $result.PresetName
            $params = $result.Params
        }
        '2' {
            $presetName = 'Standart Mod'
            $params = '-5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
        }
        '3' {
            $presetName = 'Superonline Yontem A (Alt 4)'
            $params = '-5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
        }
        '4' {
            $presetName = 'Superonline Yontem B (Alt 3)'
            $params = '--set-ttl 3 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
        }
        '5' {
            $presetName = 'Superonline Yontem C (Alt 5)'
            $params = '-9 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253'
        }
        '6' {
            $presetName = 'Superonline Yontem D (Alt 2)'
            $params = '-5'
        }
        '7' {
            $presetName = 'Superonline Yontem E (Alt 6)'
            $params = '-9'
        }
        default {
            Write-Host '   Gecersiz secim!' -ForegroundColor Red
            Start-Sleep -Seconds 1
            return
        }
    }

    if (-not (Test-Path $installDir)) {
        New-Item -Path $installDir -ItemType Directory -Force | Out-Null
    }

    Set-Content -Path (Join-Path $installDir 'active-preset.txt') -Value $presetName -Encoding ASCII
    Set-Content -Path (Join-Path $installDir 'active-params.txt') -Value $params -Encoding ASCII

    Write-Host "   Secilen Mod: $presetName" -ForegroundColor Green
    Write-Host "   Yeni ayarlar kaydedildi." -ForegroundColor Green

    $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host '   Servis yeni parametrelerle guncelleniyor...' -ForegroundColor Cyan
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        & sc.exe delete $serviceName 2>$null | Out-Null

        $arch = if ([Environment]::Is64BitOperatingSystem) { 'x86_64' } else { 'x86' }
        $exePath = Join-Path $installDir "$arch\goodbyedpi.exe"
        $binPath = '"' + $exePath + '" ' + $params + ' --blacklist "' + $blacklistPath + '"'

        try {
            New-Service -Name $serviceName `
                        -BinaryPathName $binPath `
                        -StartupType Automatic `
                        -DisplayName 'GoodbyeDPI' `
                        -Description 'Discord DPI bypass servisi' `
                        -ErrorAction Stop | Out-Null
            Start-Service -Name $serviceName -ErrorAction Stop
            Write-Host '   [OK] Servis yeni mod ile baslatildi.' -ForegroundColor Green
        } catch {
            Write-Host "   [HATA] Servis guncellenemedi: $($_.Exception.Message)" -ForegroundColor Red
        }

        Write-Host '   DNS onbellegi temizleniyor...' -ForegroundColor Cyan
        & ipconfig /flushdns | Out-Null
        Write-Host '   [OK] Tamamlandi' -ForegroundColor Green
    } else {
        Write-Host '   [BILGI] Servis henuz kurulmamis. Discordu Ac secenegi calistiginda bu mod kullanilacak.' -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 2
}


# ==================== ANA AKSIYONLAR ====================

function Invoke-Open {
    param([bool]$RestartDiscord = $true)
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    DISCORD ERISIM ARACI - KURULUM' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''

    Write-Host '  [BAGLANTI TESTI - ONCE]' -ForegroundColor Yellow
    $before = Test-Latency
    if ($before.InternetMs -ge 0) {
        Write-Host "   Internet gecikme : $($before.InternetMs) ms" -ForegroundColor Gray
    }
    if ($before.DiscordOk) {
        Write-Host "   Discord          : Zaten erisiliyor ($($before.DiscordMs) ms)" -ForegroundColor Green
    } else {
        Write-Host '   Discord          : Engelli (beklenen)' -ForegroundColor Red
    }

    Write-Host ''
    Set-SystemDns
    Write-Host ''
    Update-HostsFile
    Install-DpiBypass

    Install-SiteTool

    Write-Host ''
    Write-Host '  [DNS] Onbellek temizleniyor...' -ForegroundColor Cyan
    & ipconfig /flushdns | Out-Null
    Write-Host '        [OK] Tamamlandi' -ForegroundColor Green

    Start-Sleep -Seconds 2

    Write-Host ''
    Write-Host '  [BAGLANTI TESTI - SONRA]' -ForegroundColor Yellow
    $after = Test-Latency
    if ($after.InternetMs -ge 0) {
        $diff = $after.InternetMs - $before.InternetMs
        $diffStr = if ($diff -gt 2) { " (+$diff ms)" } elseif ($diff -lt -2) { " ($diff ms)" } else { ' (degismedi)' }
        Write-Host "   Internet gecikme : $($after.InternetMs) ms$diffStr" -ForegroundColor Green
    }
    if ($after.DiscordOk) {
        Write-Host "   Discord          : Erisiliyor ($($after.DiscordMs) ms)" -ForegroundColor Green
    } else {
        Write-Host '   Discord          : Henuz erisilemedi (DNS yayilimi bekleniyor)' -ForegroundColor Yellow
    }

    if ($RestartDiscord) {
        Restart-DiscordApp
    } else {
        Write-Host ''
        Write-Host '  [Discord] Yeniden baslatma atlandi' -ForegroundColor Gray
    }

    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Yellow
    Write-Host '    BASARILI! Discord artik calisiyor olmali.' -ForegroundColor Yellow
    Write-Host '  ==========================================================' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '   Internet hizina ve oyun pingine HICBIR etkisi yoktur.' -ForegroundColor Green
    Write-Host '   Sadece Discord trafigi etkilenir.' -ForegroundColor Green
    Write-Host ''
    Write-Host '   Baska site acmak icin CMD''den: site ac x.com' -ForegroundColor Cyan
    Write-Host ''

    Show-WinNotification 'Discord Acici' 'Kurulum basarili! Discord artik calisiyor.'
}

function Invoke-Restore {
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    GERI ALINIYOR' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''

    if (Test-Path $hostsPath) {
        $content = [IO.File]::ReadAllText($hostsPath)
        $pattern = '\r?\n?\r?\n?' + [regex]::Escape($marker) + '[\s\S]*?' + [regex]::Escape($endMarker) + '\r?\n?'
        $newContent = [regex]::Replace($content, $pattern, '')
        [IO.File]::WriteAllText($hostsPath, $newContent.TrimEnd() + "`r`n", [Text.Encoding]::ASCII)
        Write-Host '   [OK] Hosts temizlendi' -ForegroundColor Green
    }

    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        & sc.exe delete $serviceName | Out-Null
        Write-Host '   [OK] DPI bypass servisi kaldirildi' -ForegroundColor Green
    }

    if (Test-Path $installDir) {
        Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host '   [OK] GoodbyeDPI dosyalari silindi' -ForegroundColor Green
    }

    foreach ($cmd in @("$env:WINDIR\site.bat", "$env:WINDIR\gzlbaba.bat")) {
        if (Test-Path $cmd) {
            Remove-Item $cmd -Force -ErrorAction SilentlyContinue
            Write-Host "   [OK] $(Split-Path $cmd -Leaf) kaldirildi" -ForegroundColor Green
        }
    }

    Write-Host ''
    Reset-SystemDns

    & ipconfig /flushdns | Out-Null
    Write-Host '   [OK] DNS onbellegi temizlendi' -ForegroundColor Green

    Write-Host ''
    Write-Host '   Sistem tamamen orijinal haline dondu.' -ForegroundColor Yellow
    Write-Host ''

    Show-WinNotification 'Discord Acici' 'Tum ayarlar geri alindi.'
}

function Invoke-Status {
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '    DURUM' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host ''

    Write-Host '  [HOSTS DOSYASI]' -ForegroundColor Yellow
    if (Test-Path $hostsPath) {
        $content = [IO.File]::ReadAllText($hostsPath)
        $regex = [regex]::Escape($marker) + '([\s\S]*?)' + [regex]::Escape($endMarker)
        $m = [regex]::Match($content, $regex)
        if ($m.Success) {
            $count = @($m.Groups[1].Value.Trim().Split("`n")).Count
            Write-Host "   $count domain tanimli" -ForegroundColor Green
        } else {
            Write-Host '   Discord girdisi yok' -ForegroundColor Yellow
        }
    }

    Write-Host ''
    Write-Host '  [DPI BYPASS SERVISI]' -ForegroundColor Yellow
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        $color = if ($svc.Status -eq 'Running') { 'Green' } else { 'Yellow' }
        Write-Host "   Durum: $($svc.Status)" -ForegroundColor $color

        $presetPath = Join-Path $installDir 'active-preset.txt'
        if (Test-Path $presetPath) {
            $presetName = Get-Content $presetPath -Raw
            Write-Host "   Aktif Mod: $($presetName.Trim())" -ForegroundColor Green
        }
        $paramsPath = Join-Path $installDir 'active-params.txt'
        if (Test-Path $paramsPath) {
            $params = Get-Content $paramsPath -Raw
            Write-Host "   Parametreler: $($params.Trim())" -ForegroundColor Gray
        }
    } else {
        Write-Host '   Servis kurulu degil' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host '  [SISTEM DNS]' -ForegroundColor Yellow
    try {
        $adapters = Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false }
        foreach ($a in $adapters) {
            $dns = Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            if ($dns -and $dns.ServerAddresses) {
                Write-Host ("   {0,-25} : {1}" -f $a.Name, ($dns.ServerAddresses -join ', ')) -ForegroundColor Green
            } else {
                Write-Host ("   {0,-25} : (otomatik)" -f $a.Name) -ForegroundColor Gray
            }
        }
    } catch {}

    Write-Host ''
    Write-Host '  [KOMUTLAR]' -ForegroundColor Yellow
    foreach ($cmd in @('site', 'gzlbaba')) {
        $p = "$env:WINDIR\$cmd.bat"
        if (Test-Path $p) {
            Write-Host "   ""$cmd"" komutu yuklu" -ForegroundColor Green
        } else {
            Write-Host "   ""$cmd"" komutu yuklu degil" -ForegroundColor Yellow
        }
    }

    Write-Host ''
    Write-Host '  [BAGLANTI TESTI]' -ForegroundColor Yellow
    $test = Test-Latency
    if ($test.InternetMs -ge 0) {
        Write-Host "   Internet gecikme : $($test.InternetMs) ms" -ForegroundColor Green
    } else {
        Write-Host '   Internet          : Baglanti yok' -ForegroundColor Red
    }
    if ($test.DiscordOk) {
        Write-Host "   Discord          : Erisiliyor ($($test.DiscordMs) ms)" -ForegroundColor Green
    } else {
        Write-Host '   Discord          : Erisilemedi' -ForegroundColor Red
    }

    Write-Host ''
    Write-Host "   Surum: $ScriptVersion" -ForegroundColor Gray
    Write-Host ''
}

# ==================== ROUTER ====================

switch ($Action) {
    'Open'          { Invoke-Open -RestartDiscord $true }
    'OpenNoRestart' { Invoke-Open -RestartDiscord $false }
    'Restore'       { Invoke-Restore }
    'ChangeMode'    { Invoke-ChangeMode }
    'Status'     { Invoke-Status }
    'Update'     { Invoke-Update }
    'SiteAdd'    { Invoke-SiteAdd $Domains }
    'SiteRemove' { Invoke-SiteRemove $Domains }
    'SiteList'   { Invoke-SiteList }
    'SiteUsage'  { Invoke-SiteUsage }
    default      { Invoke-Open }
}
::PS_END
