@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    pause
    exit /b 1
)

title Windows System Cleaner v2.0
color 0A

echo.
echo =====================================================
echo   Windows System Deep Cleaner v2.0
echo   Temp / Cache / Logs / Registry Junk
echo =====================================================
echo.
echo [INFO] Please wait 1-3 minutes, do not close...
echo.
timeout /t 3 /nobreak >nul

:: -----------------------------------
:: Step 1 - Stop services
:: -----------------------------------
echo [1/8] Stopping related services...
net stop "Windows Search" >nul 2>&1
net stop "SysMain"        >nul 2>&1
net stop "wuauserv"       >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 2 - User temp files
:: -----------------------------------
echo [2/8] Cleaning user temp files...
if exist "%TEMP%" (
    pushd "%TEMP%"
    del /f /s /q *.* >nul 2>&1
    for /d %%d in (*) do rd /s /q "%%d" >nul 2>&1
    popd
)
if exist "%TMP%" (
    pushd "%TMP%"
    del /f /s /q *.* >nul 2>&1
    for /d %%d in (*) do rd /s /q "%%d" >nul 2>&1
    popd
)
if exist "%USERPROFILE%\AppData\Local\Temp" (
    pushd "%USERPROFILE%\AppData\Local\Temp"
    del /f /s /q *.* >nul 2>&1
    for /d %%d in (*) do rd /s /q "%%d" >nul 2>&1
    popd
)
echo       Done.

:: -----------------------------------
:: Step 3 - System temp / cache
:: -----------------------------------
echo [3/8] Cleaning system temp and cache...
if exist "%SystemRoot%\Temp" (
    pushd "%SystemRoot%\Temp"
    del /f /s /q *.* >nul 2>&1
    for /d %%d in (*) do rd /s /q "%%d" >nul 2>&1
    popd
)
if exist "%SystemRoot%\Prefetch" (
    del /f /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
)
if exist "%LOCALAPPDATA%\D3DSCache" (
    del /f /s /q "%LOCALAPPDATA%\D3DSCache\*.*" >nul 2>&1
)
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" del /f /s /q "%LOCALAPPDATA%\NVIDIA\DXCache\*.*" >nul 2>&1
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" del /f /s /q "%LOCALAPPDATA%\NVIDIA\GLCache\*.*" >nul 2>&1
if exist "%LOCALAPPDATA%\AMD\DxCache"    del /f /s /q "%LOCALAPPDATA%\AMD\DxCache\*.*"    >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 4 - Browser cache
:: -----------------------------------
echo [4/8] Cleaning browser cache...
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%p\cache2"       rd /s /q "%%p\cache2"       >nul 2>&1
        if exist "%%p\OfflineCache" rd /s /q "%%p\OfflineCache" >nul 2>&1
    )
)
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 5 - Event logs
:: -----------------------------------
echo [5/8] Clearing event logs...
for /f "tokens=*" %%G in ('wevtutil el') do (
    wevtutil cl "%%G" >nul 2>&1
)
if exist "%SystemRoot%\Logs\CBS\CBS.log"     del /f /q "%SystemRoot%\Logs\CBS\CBS.log"     >nul 2>&1
if exist "%SystemRoot%\Logs\DISM\dism.log"   del /f /q "%SystemRoot%\Logs\DISM\dism.log"   >nul 2>&1
if exist "%SystemRoot%\inf\setupapi.dev.log" del /f /q "%SystemRoot%\inf\setupapi.dev.log" >nul 2>&1
if exist "%SystemRoot%\inf\setupapi.app.log" del /f /q "%SystemRoot%\inf\setupapi.app.log" >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 6 - Windows Update cache
:: -----------------------------------
echo [6/8] Cleaning Windows Update cache...
net stop wuauserv >nul 2>&1
net stop bits     >nul 2>&1
net stop cryptsvc >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution\Download" (
    rd /s /q "%SystemRoot%\SoftwareDistribution\Download" >nul 2>&1
    md       "%SystemRoot%\SoftwareDistribution\Download" >nul 2>&1
)
if exist "%SystemRoot%\SoftwareDistribution\DataStore\Logs" (
    del /f /s /q "%SystemRoot%\SoftwareDistribution\DataStore\Logs\*.*" >nul 2>&1
)
net start wuauserv >nul 2>&1
net start bits     >nul 2>&1
net start cryptsvc >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 7 - Registry cleanup
:: -----------------------------------
echo [7/8] Cleaning registry junk...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"          /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"       /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery"   /va /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"       /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /va /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache"     /v AppCompatCache /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontCache"              /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"        /va /f >nul 2>&1
ie4uinit.exe -ClearIconCache >nul 2>&1
echo       Done.

:: -----------------------------------
:: Step 8 - Disk Cleanup (cleanmgr)
:: -----------------------------------
echo [8/8] Running Disk Cleanup...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files"                /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin"                    /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache"                /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files"           /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache"               /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files"    /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files"       /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files"                /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files" /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files"    /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup"                 /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files"  /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files"      /v StateFlags0100 /t REG_DWORD /d 2 /f >nul 2>&1
cleanmgr /sagerun:100 >nul 2>&1
echo       Done.

:: -----------------------------------
:: Restart services + Explorer
:: -----------------------------------
echo.
echo [+] Restarting services...
net start "Windows Search" >nul 2>&1
net start "SysMain"        >nul 2>&1
net start "wuauserv"       >nul 2>&1

echo [+] Refreshing Explorer...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe

:: -----------------------------------
:: Summary
:: -----------------------------------
echo.
echo =====================================================
echo   ALL DONE!
echo =====================================================
echo   [OK] User and system temp files
echo   [OK] Prefetch / DirectX / GPU shader cache
echo   [OK] Edge / Chrome / Firefox cache
echo   [OK] Windows event logs / CBS / DISM logs
echo   [OK] Windows Update download cache
echo   [OK] Registry: RunMRU / MUICache / UserAssist
echo   [OK] Registry: AppCompat / FontCache junk
echo   [OK] Disk Cleanup: Recycle Bin / Thumbnails
echo =====================================================
echo   TIP: Reboot for full effect.
echo =====================================================
echo.

set /p REBOOT=  Reboot now? (y/N): 
if /i "%REBOOT%"=="y" (
    shutdown /r /t 10 /c "Cleanup done. Rebooting in 10s..."
    echo  [INFO] To cancel: shutdown /a
)

echo.
pause
endlocal
