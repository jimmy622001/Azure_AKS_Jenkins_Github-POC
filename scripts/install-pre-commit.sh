#!/bin/bash
# Script to install the pre-commit hook

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "${YELLOW}Installing pre-commit hook to detect sensitive data...${NC}"

# Check if the .git directory exists
if [ ! -d ".git" ]; then
  echo "${RED}Error: .git directory not found. Make sure you're in the root of the repository.${NC}"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Check if pre-commit already exists
if [ -f ".git/hooks/pre-commit" ]; then
  echo "${YELLOW}A pre-commit hook already exists.${NC}"
  read -p "Do you want to overwrite it? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Pre-commit hook installation cancelled.${NC}"
    exit 0
  fi
fi

# Copy the pre-commit hook
cp scripts/pre-commit-hook .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "${GREEN}Pre-commit hook installed successfully!${NC}"
echo "${YELLOW}This hook will check for sensitive data in your commits.${NC}"
exit 0