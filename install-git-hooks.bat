@echo off
:: Script to install Git hooks on Windows

:: Define paths
set HOOK_DIR=.git\hooks
set PRE_COMMIT_HOOK=%HOOK_DIR%\pre-commit
set HOOKS_SOURCE_DIR=git-hooks

:: Ensure the hooks source directory exists
if not exist %HOOKS_SOURCE_DIR% mkdir %HOOKS_SOURCE_DIR%

:: Create the pre-commit hook in the source directory
echo @echo off > %HOOKS_SOURCE_DIR%\pre-commit
echo :: Pre-commit hook to prevent committing sensitive data >> %HOOKS_SOURCE_DIR%\pre-commit
echo echo Running security checks... >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo :: Find files being committed >> %HOOKS_SOURCE_DIR%\pre-commit
echo for /f "tokens=*" %%a in ('git diff --cached --name-only --diff-filter^=ACM') do ( >> %HOOKS_SOURCE_DIR%\pre-commit
echo   call :check_file "%%a" >> %HOOKS_SOURCE_DIR%\pre-commit
echo ) >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo :: Check if any terraform.tfvars files are being committed >> %HOOKS_SOURCE_DIR%\pre-commit
echo for /f "tokens=*" %%a in ('git diff --cached --name-only --diff-filter^=ACM ^| findstr /r "terraform\.tfvars$"') do ( >> %HOOKS_SOURCE_DIR%\pre-commit
echo   echo ERROR: You're trying to commit terraform.tfvars file: %%a >> %HOOKS_SOURCE_DIR%\pre-commit
echo   echo These files may contain sensitive data. Use .tfvars.example instead. >> %HOOKS_SOURCE_DIR%\pre-commit
echo   exit /b 1 >> %HOOKS_SOURCE_DIR%\pre-commit
echo ) >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo echo No sensitive data found. Proceeding with commit. >> %HOOKS_SOURCE_DIR%\pre-commit
echo exit /b 0 >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo :check_file >> %HOOKS_SOURCE_DIR%\pre-commit
echo set file=%%~1 >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo :: Skip binary files >> %HOOKS_SOURCE_DIR%\pre-commit
echo :: [Windows limitation - simplified check] >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo :: Check for sensitive patterns >> %HOOKS_SOURCE_DIR%\pre-commit
echo findstr /i /r "password.*= passwd.*= secret.*= key.*= token.*= credential.*=" %%file%% >nul >> %HOOKS_SOURCE_DIR%\pre-commit
echo if not errorlevel 1 ( >> %HOOKS_SOURCE_DIR%\pre-commit
echo   echo ERROR: Potential password/secret/token found in %%file%% >> %HOOKS_SOURCE_DIR%\pre-commit
echo   findstr /i /r "password.*= passwd.*= secret.*= key.*= token.*= credential.*=" %%file%% >> %HOOKS_SOURCE_DIR%\pre-commit
echo   exit /b 1 >> %HOOKS_SOURCE_DIR%\pre-commit
echo ) >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo findstr /i /r "BEGIN RSA PRIVATE KEY BEGIN DSA PRIVATE KEY BEGIN EC PRIVATE KEY BEGIN OPENSSH PRIVATE KEY" %%file%% >nul >> %HOOKS_SOURCE_DIR%\pre-commit
echo if not errorlevel 1 ( >> %HOOKS_SOURCE_DIR%\pre-commit
echo   echo ERROR: Potential SSH private key found in %%file%% >> %HOOKS_SOURCE_DIR%\pre-commit
echo   findstr /i /r "BEGIN RSA PRIVATE KEY BEGIN DSA PRIVATE KEY BEGIN EC PRIVATE KEY BEGIN OPENSSH PRIVATE KEY" %%file%% >> %HOOKS_SOURCE_DIR%\pre-commit
echo   exit /b 1 >> %HOOKS_SOURCE_DIR%\pre-commit
echo ) >> %HOOKS_SOURCE_DIR%\pre-commit
echo. >> %HOOKS_SOURCE_DIR%\pre-commit
echo exit /b 0 >> %HOOKS_SOURCE_DIR%\pre-commit

:: Create the hooks directory if it doesn't exist
if not exist %HOOK_DIR% mkdir %HOOK_DIR%

:: Copy the hook to the git hooks directory
copy /Y %HOOKS_SOURCE_DIR%\pre-commit %PRE_COMMIT_HOOK%

echo Git pre-commit hook installed successfully!
echo The hook will help prevent committing sensitive data.