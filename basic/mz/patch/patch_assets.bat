@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Chronos Seal - Incremental Patch

cd /d "%~dp0"

set "PATCH_DIR=Patch"
set "SUMMARY_FILE=_cs_patch_summary.txt"

cls
echo ============================================================
echo   Chronos Seal - Incremental Patch Builder
echo ============================================================
echo.
echo   Run this BAT from your PROJECT ROOT directory.
echo.
echo   First run  : creates baseline manifest.json
echo   Later runs : outputs only changed files, then packs a zip
echo.
echo   Prerequisites:
echo     - patch_builder.js     (same directory as this BAT)
echo     - encrypt_config.json  (needed for first run)
echo.
echo   Press any key to continue . . .
pause >nul

:: Node.js check
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo   [ERROR] Node.js not found.
    pause >nul
    exit /b 1
)
for /f "delims=" %%v in ('node -v 2^>nul') do set "NODE_VER=%%v"
echo   [OK] Node.js !NODE_VER!

if not exist "patch_builder.js" (
    echo   [ERROR] patch_builder.js not found in current directory.
    pause >nul
    exit /b 1
)

if not exist "manifest.json" (
    if not exist "encrypt_config.json" (
        echo   [ERROR] First run requires encrypt_config.json
        pause >nul
        exit /b 1
    )
    echo.
    echo   [INFO] No manifest.json - FIRST RUN.
    echo          Will scan project and create baseline.
    echo.
    echo   Press any key to continue . . .
    pause >nul
) else (
    echo.
    echo   [INFO] manifest.json found - will compare and build patch.
    echo.
    echo   Press any key to continue . . .
    pause >nul
)

if exist "%SUMMARY_FILE%" del /q "%SUMMARY_FILE%" 2>nul

node "patch_builder.js"
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Build failed.
    pause >nul
    exit /b 1
)

if not exist "%SUMMARY_FILE%" (
    echo   [ERROR] Summary not produced.
    pause >nul
    exit /b 1
)

set "ENC_COUNT=0"
set "PLAIN_COUNT=0"
set "FAIL_COUNT=0"
for /f "tokens=1,2,3 delims=," %%a in ('type "%SUMMARY_FILE%"') do (
    set "ENC_COUNT=%%a"
    set "PLAIN_COUNT=%%b"
    set "FAIL_COUNT=%%c"
)

set /a TOTAL=!ENC_COUNT!+!PLAIN_COUNT!

if !TOTAL!==0 (
    if exist "manifest.json" (
        echo.
        echo   [INFO] Baseline ready. No patch output.
    ) else (
        echo.
        echo   [INFO] No changes. Nothing to patch.
    )
    del /q "%SUMMARY_FILE%" 2>nul
    pause >nul
    exit /b 0
)

if not "!FAIL_COUNT!"=="0" (
    echo.
    echo   [ERROR] !FAIL_COUNT! file^(s^) failed.
    pause >nul
    exit /b 1
)

set "PATCH_NAME=patch_MZ.zip"
if exist "%PATCH_NAME%" del /q "%PATCH_NAME%" 2>nul

powershell -NoProfile -Command "Compress-Archive -Path 'Patch\*' -DestinationPath '%PATCH_NAME%' -Force"

if not exist "%PATCH_NAME%" (
    echo   [ERROR] Failed to create %PATCH_NAME%
    pause >nul
    exit /b 1
)

for %%A in ("%PATCH_NAME%") do set "PATCH_SIZE=%%~zA"
set /a PATCH_KB=!PATCH_SIZE!/1024

del /q "%SUMMARY_FILE%" 2>nul

echo.
echo ============================================================
echo   Patch built: %PATCH_NAME% (!PATCH_KB! KB^)
echo   Encrypted: !ENC_COUNT!  Plain: !PLAIN_COUNT!
echo ============================================================
echo.
echo   Players unzip %PATCH_NAME% into game root.
echo.
pause >nul
endlocal
exit /b 0