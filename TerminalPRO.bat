@echo off
setlocal EnableExtensions
title PowerShell Terminal Setup

echo ============================================================
echo PowerShell Terminal Enhancement Setup
echo ============================================================
echo.

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Windows PowerShell was not found.
    pause
    exit /b 1
)

echo [1/5] Configuring execution policy for current user...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop; Write-Host '[OK] CurrentUser policy = RemoteSigned' } catch { Write-Warning ('Unable to change policy. It may be controlled by company policy: ' + $_.Exception.Message) }"

echo.
echo [2/5] Installing NuGet provider if required...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) { try { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop; Write-Host '[OK] NuGet installed' } catch { Write-Warning $_.Exception.Message } } else { Write-Host '[OK] NuGet already available' }"

echo.
echo [3/5] Installing/updating PSReadLine...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"try { Install-Module PSReadLine -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop; Write-Host '[OK] PSReadLine installed/updated' } catch { Write-Warning ('PSReadLine installation failed: ' + $_.Exception.Message) }"

echo.
echo [4/5] Detecting actual PowerShell profile location...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$p=$PROFILE.CurrentUserCurrentHost; Write-Host ('Profile: ' + $p); $dir=Split-Path -Parent $p; if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }; if (!(Test-Path $p)) { New-Item -ItemType File -Path $p -Force | Out-Null }; try { Unblock-File -LiteralPath $p -ErrorAction SilentlyContinue } catch {}"

echo.
echo [5/5] Adding terminal configuration...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$p=$PROFILE.CurrentUserCurrentHost; $start='# BEGIN DEV TERMINAL CONFIG'; $end='# END DEV TERMINAL CONFIG'; $block=@'
# BEGIN DEV TERMINAL CONFIG

Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# END DEV TERMINAL CONFIG
'@; $existing=''; if(Test-Path $p){$existing=Get-Content $p -Raw}; if($existing -match '(?s)# BEGIN DEV TERMINAL CONFIG.*?# END DEV TERMINAL CONFIG'){ $existing=[regex]::Replace($existing,'(?s)# BEGIN DEV TERMINAL CONFIG.*?# END DEV TERMINAL CONFIG',$block); Set-Content -Path $p -Value $existing -Encoding UTF8 } else { Add-Content 
