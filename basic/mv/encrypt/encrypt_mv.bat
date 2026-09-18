@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Chronos Seal - MV Asset Encryption

cd /d "%~dp0"

set "SCAN_FILE=_cs_scan.txt"
set "RESULT_FILE=_cs_result.txt"
set "VERIFY_FILE=_cs_verify.txt"
set "ORIGINALS_FILE=_cs_originals.txt"
set "BACKUP_DIR=_source_backup"
set "SEED_BACKUP=_mv_seed.txt"

:: ============================================================
:: STEP 0 - Welcome
:: ============================================================
cls
echo ============================================================
echo   Chronos Seal - MV Asset Encryption
echo ============================================================
echo.
echo   Encrypts images and audio IN-PLACE inside www\.
echo.
echo   Prerequisites:
echo     - encrypt_config.json    (from mv_config.bat)
echo     - www\                    (MV game directory)
echo     - encrypt_assets_mv.js   (this tool)
echo.
echo   A backup of originals will be placed in %BACKUP_DIR%\
echo   Make sure your source project is also backed up.
echo.
echo   Press any key to continue . . .
pause >nul

:: ============================================================
:: STEP 1 - Node.js check
:: ============================================================
echo.
echo [Step 1/7] Checking Node.js environment . . .
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo   [ERROR] Node.js not found.
    pause >nul
    exit /b 1
)
for /f "delims=" %%v in ('node -v 2^>nul') do set "NODE_VER=%%v"
echo   [OK] Found Node.js !NODE_VER!

:: ============================================================
:: STEP 2 - Required files
:: ============================================================
echo.
echo [Step 2/7] Checking required files . . .
echo.

if not exist "encrypt_config.json" (
    echo   [ERROR] encrypt_config.json not found.
    echo           Run mv_config.bat first.
    pause >nul
    exit /b 1
)
echo   [OK] encrypt_config.json found.

if not exist "encrypt_assets_mv.js" (
    echo   [ERROR] encrypt_assets_mv.js not found.
    pause >nul
    exit /b 1
)
echo   [OK] encrypt_assets_mv.js found.

if not exist "www\" (
    echo   [ERROR] www\ directory not found.
    pause >nul
    exit /b 1
)
echo   [OK] www\ directory found.

echo.
echo   Press any key to scan asset files . . .
pause >nul

:: ============================================================
:: STEP 3 - Scan
:: ============================================================
echo.
echo [Step 3/7] Scanning asset files . . .
echo.

if exist "%SCAN_FILE%" del /q "%SCAN_FILE%" 2>nul

node "encrypt_assets_mv.js" --scan
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Scan failed.
    pause >nul
    exit /b 1
)

if not exist "%SCAN_FILE%" (
    echo   [ERROR] Scan did not produce result file.
    pause >nul
    exit /b 1
)

set "TOTAL_FILES=0"
set /p TOTAL_FILES=<"%SCAN_FILE%"

if "%TOTAL_FILES%"=="0" (
    echo.
    echo   [INFO] No asset files found.
    pause >nul
    exit /b 0
)

echo.
echo   [OK] Found %TOTAL_FILES% asset file^(s^) to encrypt.
echo.
echo   Press any key to start encryption . . .
pause >nul

:: ============================================================
:: STEP 4 - Encrypt
:: ============================================================
echo.
echo [Step 4/7] Encrypting . . .
echo.

if exist "%RESULT_FILE%"    del /q "%RESULT_FILE%" 2>nul
if exist "%ORIGINALS_FILE%" del /q "%ORIGINALS_FILE%" 2>nul
if exist "%BACKUP_DIR%\"    rmdir /s /q "%BACKUP_DIR%" 2>nul

node "encrypt_assets_mv.js" --encrypt
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Encryption aborted.
    pause >nul
    exit /b 1
)

if not exist "%RESULT_FILE%" (
    echo   [ERROR] Encryption did not produce result file.
    pause >nul
    exit /b 1
)

set "SUCCESS_COUNT=0"
set "FAIL_COUNT=0"
for /f "tokens=1,2 delims=," %%a in ('type "%RESULT_FILE%"') do (
    set "SUCCESS_COUNT=%%a"
    set "FAIL_COUNT=%%b"
)

if not "%FAIL_COUNT%"=="0" (
    echo.
    echo   [ERROR] %FAIL_COUNT% file^(s^) failed.
    pause >nul
    exit /b 1
)

echo.
echo   [OK] Successfully encrypted %SUCCESS_COUNT% file^(s^).
echo.
echo   Press any key to verify encryption . . .
pause >nul

:: ============================================================
:: STEP 5 - Verify
:: ============================================================
echo.
echo [Step 5/7] Verifying . . .
echo.

if exist "%VERIFY_FILE%" del /q "%VERIFY_FILE%" 2>nul

node "encrypt_assets_mv.js" --verify
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Verification FAILED.
    echo           Encrypted files could not be decrypted correctly.
    echo           DO NOT distribute. Restore from backup.
    pause >nul
    exit /b 1
)

set "VERIFY_RESULT="
set /p VERIFY_RESULT=<"%VERIFY_FILE%"
echo   [OK] Verification passed: %VERIFY_RESULT%
echo.

:: ============================================================
:: STEP 6 - Cleanup confirmation (with backup check)
:: ============================================================
echo [Step 6/7] Sensitive file cleanup
echo.

if not exist "%BACKUP_DIR%\" (
    echo   [ERROR] Backup directory not found: %BACKUP_DIR%\
    echo           Aborting deletion to prevent data loss.
    pause >nul
    exit /b 1
)

set "BACKUP_COUNT=0"
for /f %%F in ('dir /b /a-d /s "%BACKUP_DIR%\*" ^| find /c /v ""') do (
    set "BACKUP_COUNT=%%F"
)

if "!BACKUP_COUNT!"=="0" (
    echo   [ERROR] Backup directory is empty.
    echo           Aborting deletion to prevent data loss.
    pause >nul
    exit /b 1
)

echo   Backup verified: !BACKUP_COUNT! file^(s^) in %BACKUP_DIR%\
echo.
echo   The following will be permanently DELETED from www\:
echo     - All ORIGINAL asset files listed in the encryption log
echo       ^(plaintext images and audio^)
echo     - encrypt_config.json
echo       ^(contains the derivation seed^)
echo.
echo   WARNING: This action CANNOT be undone.
echo   Make sure your source project is backed up elsewhere.
echo.
echo   Press any key to proceed . . .
pause >nul

:: ============================================================
:: STEP 7 - Delete sensitive files
:: ============================================================
echo.
echo [Step 7/7] Deleting sensitive files . . .
echo.

if not exist "%ORIGINALS_FILE%" (
    echo   [ERROR] Original file list not found.
    echo           Aborting deletion to prevent data loss.
    pause >nul
    exit /b 1
)

set "DELETED=0"

for /f "usebackq delims=" %%f in ("%ORIGINALS_FILE%") do (
    if exist "%%f" (
        del /q "%%f" 2>nul
        set /a DELETED+=1
    )
)

echo   [OK] Removed !DELETED! original asset file^(s^).

if exist "encrypt_config.json" (
    del /q "encrypt_config.json" 2>nul
    echo   [OK] encrypt_config.json removed.
)

if exist "%SCAN_FILE%"       del /q "%SCAN_FILE%"       2>nul
if exist "%RESULT_FILE%"     del /q "%RESULT_FILE%"     2>nul
if exist "%VERIFY_FILE%"     del /q "%VERIFY_FILE%"     2>nul
if exist "%ORIGINALS_FILE%"  del /q "%ORIGINALS_FILE%"  2>nul

echo.
echo ============================================================
echo   Encryption complete.
echo ============================================================
echo.
echo   Next steps:
echo     1. Run obfuscate.bat to protect the wrapper plugin
echo     2. Test the game locally
echo     3. Package and distribute
echo.
echo   IMPORTANT: The .enc files are now the ONLY copies in www\.
echo              DO NOT re-run this tool on the same package.
echo.
echo ============================================================
echo   CRITICAL - BACKUP YOUR SOURCE ASSETS
echo ============================================================
echo.
echo   A full copy of your original assets is in:
echo     %BACKUP_DIR%\
echo.
echo   PLEASE COMPRESS THIS FOLDER INTO A ZIP ARCHIVE,
echo   THEN MOVE THE ZIP OUTSIDE THE RELEASE PACKAGE.
echo.
echo   DO NOT leave %BACKUP_DIR%\ inside the game folder.
echo   DO NOT ship %BACKUP_DIR%\ with the release package.
echo.
echo   Keep your source project and %SEED_BACKUP% safe.
echo   You need them for future updates and patches.
echo.
pause >nul

endlocal
exit /b 0