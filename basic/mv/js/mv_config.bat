@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Chronos Seal - MV Plugin Setup

cd /d "%~dp0"

set "SEED_BACKUP=_mv_seed.txt"

:: ============================================================
:: STEP 0 - Welcome
:: ============================================================
cls
echo ============================================================
echo   Chronos Seal - MV Plugin Setup
echo ============================================================
echo.
echo   Interactive setup. Choose one shell from five candidates.
echo.
echo   Press any key to continue . . .
pause >nul

:: ============================================================
:: STEP 1 - Node.js
:: ============================================================
echo.
echo [Step 1/8] Checking Node.js . . .
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo   [ERROR] Node.js not found. Please install Node.js.
    pause >nul
    exit /b 1
)
for /f "delims=" %%v in ('node -v 2^>nul') do set "NODE_VER=%%v"
echo   [OK] Node.js !NODE_VER!

:: ============================================================
:: STEP 2 - Shell selection
:: ============================================================
echo.
echo [Step 2/8] Choose wrapper shell
echo.
echo     [1] CLARE_LocalizationCore    Multi-language core
echo     [2] CLARE_ImageCache          Bitmap & audio LRU cache
echo     [3] CLARE_AssetPreloader      Background preloader
echo     [4] CLARE_SaveIntegrity       Save slot integrity
echo     [5] CLARE_DLCManager          Downloadable content
echo.
set "SHELL_OPT="
set /p "SHELL_OPT=Choose [1]: "
if "!SHELL_OPT!"=="" set "SHELL_OPT=1"

if "!SHELL_OPT!"=="1" set "SHELL_NAME=CLARE_LocalizationCore"
if "!SHELL_OPT!"=="2" set "SHELL_NAME=CLARE_ImageCache"
if "!SHELL_OPT!"=="3" set "SHELL_NAME=CLARE_AssetPreloader"
if "!SHELL_OPT!"=="4" set "SHELL_NAME=CLARE_SaveIntegrity"
if "!SHELL_OPT!"=="5" set "SHELL_NAME=CLARE_DLCManager"

if "!SHELL_NAME!"=="" (
    echo   [ERROR] Invalid choice.
    pause >nul
    exit /b 1
)
echo   Using: !SHELL_NAME!

:: ============================================================
:: STEP 3 - Game name
:: ============================================================
echo.
echo [Step 3/8] Game name
echo.
set "GN="
set /p "GN=Enter game name (or leave blank): "
if "!GN!"=="" set "GN=(unnamed)"
echo   Using: !GN!

:: ============================================================
:: STEP 4 - Game version
:: ============================================================
echo.
echo [Step 4/8] Game version
echo.
set "GV="
set /p "GV=Enter game version [1.0.0]: "
if "!GV!"=="" set "GV=1.0.0"
echo   Using: !GV!

:: ============================================================
:: STEP 5 - Release date
:: ============================================================
echo.
echo [Step 5/8] Release date
echo.
set "RD="
set /p "RD=Enter release date (YYYY-MM-DD, blank = today): "
if "!RD!"=="" (
    for /f "delims=" %%d in ('node -e "console.log(new Date().toISOString().slice(0,10))"') do set "RD=%%d"
)
echo   Using: !RD!

:: ============================================================
:: STEP 6 - Seed
:: ============================================================
echo.
echo [Step 6/8] Seed
echo.
echo     [1] Auto-generate new seed (first setup)
echo     [2] Enter existing seed (rebuild)
echo.
set "SEED_OPT="
set /p "SEED_OPT=Choose [1]: "
if "!SEED_OPT!"=="" set "SEED_OPT=1"

if "!SEED_OPT!"=="1" (
    for /f "delims=" %%s in ('node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"') do set "SEED=%%s"
    echo.
    echo   Generated seed: !SEED!
    echo.
    echo   WARNING: Save it. You need it for future patches.
    echo.
) else (
    echo.
    set /p "SEED=Enter seed (64 hex chars): "
    if "!SEED!"=="" (
        echo   [ERROR] Seed cannot be empty.
        pause >nul
        exit /b 1
    )
)

:: ============================================================
:: STEP 7 - Salt
:: ============================================================
echo.
echo [Step 7/8] Salt
echo.
set "SALT="
set /p "SALT=Enter salt (blank = auto): "
if "!SALT!"=="" (
    for /f "delims=" %%s in ('node -e "console.log(Math.floor(Math.random()*4294967295))"') do set "SALT=%%s"
)
echo   Using: !SALT!

:: ============================================================
:: STEP 8 - Confirm and generate
:: ============================================================
echo.
echo [Step 8/8] Summary
echo.
echo ============================================================
echo   Shell:         !SHELL_NAME!
echo   Game name:     !GN!
echo   Game version:  !GV!
echo   Release date:  !RD!
echo   Seed:          !SEED:~0,32!...
echo   Salt:          !SALT!
echo ============================================================
echo.
echo   Press any key to generate . . .
pause >nul

echo.
echo [Running] Generating . . .
echo.

if not exist "mv_build.js" (
    echo   [ERROR] mv_build.js not found.
    pause >nul
    exit /b 1
)
if not exist "CLARE_Shell.mv.tmpl" (
    echo   [ERROR] CLARE_Shell.mv.tmpl not found.
    pause >nul
    exit /b 1
)

node "mv_build.js" --shell "!SHELL_OPT!" --name "!GN!" --version "!GV!" --date "!RD!" --seed "!SEED!" --salt "!SALT!"
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Build failed.
    pause >nul
    exit /b 1
)

(
    echo ============================================================
    echo Chronos Seal MV - Seed Backup
    echo ============================================================
    echo Shell:         !SHELL_NAME!
    echo Game name:     !GN!
    echo Game version:  !GV!
    echo Release date:  !RD!
    echo Seed:          !SEED!
    echo Salt:          !SALT!
    echo ============================================================
    echo Keep this file safe. You need these values to build patches.
    echo ============================================================
) > "%SEED_BACKUP%"

echo.
echo ============================================================
echo   Setup complete.
echo ============================================================
echo.
echo   Output files:
echo     - www\js\plugins\!SHELL_NAME!.js
echo     - encrypt_config.json
echo     - %SEED_BACKUP%
echo.
echo   Next steps:
echo     1. Place MV index.html in www\
echo     2. Run encrypt_assets.bat
echo     3. (Optional) Run obfuscate.bat
echo     4. Package and distribute
echo.
echo   WARNING: Do NOT lose %SEED_BACKUP%.
echo.
pause >nul
endlocal
exit /b 0