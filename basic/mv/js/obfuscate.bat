@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Chronos Seal - MV Plugin Obfuscator

cd /d "%~dp0"

set "PLUGIN_DIR=www\js\plugins"
set "PLUGIN_PATTERN=CLARE_*.js"
set "BACKUP_DIR=_obfuscate_backup"

:: ============================================================
:: STEP 0 - Welcome
:: ============================================================
cls
echo ============================================================
echo   Chronos Seal - MV Plugin Obfuscator
echo ============================================================
echo.
echo   Obfuscates all CLARE_*.js plugins in:
echo     %PLUGIN_DIR%\
echo.
echo   A backup of each plugin is saved to:
echo     %BACKUP_DIR%\
echo.
echo   IMPORTANT:
echo     - Run this AFTER mv_config.bat and encrypt_assets.bat
echo     - Test the game BEFORE distributing
echo     - If anything breaks, restore from backup
echo.
echo   Press any key to continue . . .
pause >nul

:: ============================================================
:: STEP 1 - Node.js / npx check
:: ============================================================
echo.
echo [Step 1/5] Checking Node.js environment . . .
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo   [ERROR] Node.js not found. Please install Node.js.
    pause >nul
    exit /b 1
)
for /f "delims=" %%v in ('node -v 2^>nul') do set "NODE_VER=%%v"
echo   [OK] Node.js !NODE_VER!

where npx >nul 2>nul
if %errorlevel% neq 0 (
    echo   [ERROR] npx not found. Reinstall Node.js with npm.
    pause >nul
    exit /b 1
)
echo   [OK] npx available.

:: 检查 obfuscator 是否已安装
set "OBF_CMD="
where javascript-obfuscator >nul 2>nul
if %errorlevel% equ 0 (
    set "OBF_CMD=javascript-obfuscator"
    echo   [OK] javascript-obfuscator found globally.
) else (
    set "OBF_CMD=npx --yes javascript-obfuscator"
    echo   [INFO] javascript-obfuscator not installed globally.
    echo          Will use npx (downloads on first run, needs network).
)

:: ============================================================
:: STEP 2 - Plugin directory check
:: ============================================================
echo.
echo [Step 2/5] Checking plugin directory . . .
echo.

if not exist "%PLUGIN_DIR%\" (
    echo   [ERROR] Directory not found: %PLUGIN_DIR%\
    pause >nul
    exit /b 1
)
echo   [OK] Directory exists.

:: 统计待混淆文件
set "TOTAL=0"
for %%F in ("%PLUGIN_DIR%\%PLUGIN_PATTERN%") do (
    set /a TOTAL+=1
)

if !TOTAL!==0 (
    echo   [ERROR] No CLARE_*.js found in %PLUGIN_DIR%\
    echo           Run mv_config.bat first.
    pause >nul
    exit /b 1
)
echo   [OK] Found !TOTAL! plugin^(s^) to obfuscate.
echo.
for %%F in ("%PLUGIN_DIR%\%PLUGIN_PATTERN%") do (
    echo     - %%~nxF
)

echo.
echo   Press any key to start obfuscation . . .
pause >nul

:: ============================================================
:: STEP 3 - Backup
:: ============================================================
echo.
echo [Step 3/5] Backing up original plugins . . .
echo.

if exist "%BACKUP_DIR%\" rmdir /s /q "%BACKUP_DIR%" 2>nul
mkdir "%BACKUP_DIR%" 2>nul

for %%F in ("%PLUGIN_DIR%\%PLUGIN_PATTERN%") do (
    copy /y "%%F" "%BACKUP_DIR%\%%~nxF" >nul
    echo   [BACKUP] %%~nxF
)

echo.
echo   Backup saved to: %BACKUP_DIR%\

:: ============================================================
:: STEP 4 - Obfuscate each plugin
:: ============================================================
echo.
echo [Step 4/5] Obfuscating . . .
echo.

set "SUCCESS=0"
set "FAILED=0"

for %%F in ("%PLUGIN_DIR%\%PLUGIN_PATTERN%") do (
    set "SRC=%%F"
    set "DST=%%F.obf"

    echo   [RUN] %%~nxF

    %OBF_CMD% "!SRC!" ^
        --output "!DST!" ^
        --compact true ^
        --control-flow-flattening false ^
        --dead-code-injection false ^
        --string-array true ^
        --string-array-encoding base64 ^
        --string-array-threshold 1.0 ^
        --identifier-names-generator hexadecimal ^
        --rename-globals true ^
        --unicode-escape-sequence false ^
        --self-defending false ^
        --disable-console-output false ^
        --reserved-names "__cs_bridge,__clare_locale_bridge" ^
        --target browser

    if errorlevel 1 (
        echo   [FAIL] %%~nxF  ^(obfuscator returned error^)
        set /a FAILED+=1
        if exist "!DST!" del /q "!DST!" 2>nul
    ) else (
        if exist "!DST!" (
            move /y "!DST!" "!SRC!" >nul
            for %%A in ("!SRC!") do set "SIZE=%%~zA"
            set /a SIZE_KB=!SIZE!/1024
            echo   [OK]   %%~nxF  ^(!SIZE_KB! KB^)
            set /a SUCCESS+=1
        ) else (
            echo   [FAIL] %%~nxF  ^(no output produced^)
            set /a FAILED+=1
        )
    )
)

:: ============================================================
:: STEP 5 - Summary
:: ============================================================
echo.
echo ============================================================
echo   Obfuscation complete.
echo ============================================================
echo.
echo   Success: !SUCCESS!
echo   Failed:  !FAILED!
echo.

if not "!FAILED!"=="0" (
    echo   [WARNING] Some plugins failed to obfuscate.
    echo.
    echo   To restore originals from backup:
    echo     xcopy /y "%BACKUP_DIR%\*" "%PLUGIN_DIR%\"
    echo.
    pause >nul
    exit /b 1
)

echo   IMPORTANT:
echo     - Test the game BEFORE distributing
echo     - Check: title screen, images, audio, save/load
echo.
echo   To restore originals from backup:
echo     xcopy /y "%BACKUP_DIR%\*" "%PLUGIN_DIR%\"
echo.
echo   Backup directory: %BACKUP_DIR%\
echo.
pause >nul
endlocal
exit /b 0