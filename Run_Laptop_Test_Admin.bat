@echo off
setlocal
title Laptop Full Test Kit V2 - Run as Administrator

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang yeu cau quyen Administrator...
    set "BAT_PATH=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c', \"\"\"$env:BAT_PATH\"\"\" -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo ============================================================
echo Laptop Full Test Kit V2
echo ============================================================
echo Khuyen nghi tai cua hang:
echo - Chay Quick Check truoc.
echo - Extended Test chi chay neu shop cho test 5-10 phut.
echo.
pause

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Laptop_Full_Check.ps1"

echo.
echo Da chay xong. Nhan phim bat ky de thoat...
pause >nul
endlocal
