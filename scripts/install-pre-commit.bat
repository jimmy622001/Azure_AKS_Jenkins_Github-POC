@echo off
REM Script to install the pre-commit hook for Windows users

echo Installing pre-commit hook to detect sensitive data...

REM Check if the .git directory exists
if not exist ".git" (
  echo Error: .git directory not found. Make sure you're in the root of the repository.
  exit /b 1
)

REM Create hooks directory if it doesn't exist
if not exist ".git\hooks" mkdir ".git\hooks"

REM Check if pre-commit already exists
if exist ".git\hooks\pre-commit" (
  echo A pre-commit hook already exists.
  set /p REPLY="Do you want to overwrite it? (y/n) "
  if /i not "%REPLY%"=="y" (
    echo Pre-commit hook installation cancelled.
    exit /b 0
  )
)

REM Copy the pre-commit hook
copy /y "scripts\pre-commit-hook" ".git\hooks\pre-commit"

echo Pre-commit hook installed successfully!
echo This hook will check for sensitive data in your commits.
exit /b 0