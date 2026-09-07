@echo off
setlocal

echo [1/4] Checking PowerShell profile directory...
if not exist "%USERPROFILE%\Documents\WindowsPowerShell" (
    mkdir "%USERPROFILE%\Documents\WindowsPowerShell"
)

echo [2/4] Installing NuGet provider if missing...
powershell -Command "if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }"

echo [3/4] Installing or updating PSReadLine module for current user...
powershell -Command "Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber"

echo [4/4] Writing configuration to PowerShell profile...
(
    echo # Import the updated module
    echo Import-Module PSReadLine
    echo.
    echo # Enable history predictions and set the view to a popup list
    echo Set-PSReadLineOption -PredictionSource History
    echo Set-PSReadLineOption -PredictionViewStyle ListView
    echo.
    echo # Save command history instantly so it syncs across terminal tabs and VS Code
    echo Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    echo.
    echo # Enable menu completion for the Tab key
    echo Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    echo.
    echo # Enable Ctrl+R to fuzzy-search through your past command history
    echo Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
) > "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

echo.
echo Setup completed successfully! Restart your Windows Terminal or VS Code to apply changes.
pause