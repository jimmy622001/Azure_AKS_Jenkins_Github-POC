#!/bin/bash

# Script to install Git hooks

# Define paths
HOOK_DIR=".git/hooks"
PRE_COMMIT_HOOK="${HOOK_DIR}/pre-commit"
HOOKS_SOURCE_DIR="git-hooks"

# Ensure the hooks source directory exists
mkdir -p "${HOOKS_SOURCE_DIR}"

# Create the pre-commit hook in the source directory
cat > "${HOOKS_SOURCE_DIR}/pre-commit" << 'EOF'
#!/bin/bash

# Pre-commit hook to prevent committing sensitive data
echo "Running security checks..."

# Find files being committed
FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Patterns to check for
PASSWORD_PATTERN='password.*=|passwd.*=|secret.*=|key.*=|token.*=|credential.*='
SSH_KEY_PATTERN='BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY'
IP_PATTERN='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
AWS_KEY_PATTERN='(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}'
TERRAFORM_TFVARS='terraform\.tfvars(?!\.example)'

# Check for .tfvars files (except .tfvars.example)
TFVARS_FILES=$(echo "$FILES" | grep -E "$TERRAFORM_TFVARS" || true)
if [ -n "$TFVARS_FILES" ]; then
  echo "ERROR: You're trying to commit terraform.tfvars files:"
  echo "$TFVARS_FILES"
  echo "These files may contain sensitive data. Use .tfvars.example instead."
  exit 1
fi

# Check for sensitive patterns
for FILE in $FILES; do
  # Skip binary files
  if file "$FILE" | grep -q "binary"; then
    continue
  fi
  
  # Check for sensitive data patterns
  if grep -E -q "$PASSWORD_PATTERN" "$FILE"; then
    echo "ERROR: Potential password/secret/token found in $FILE"
    grep -E --color "$PASSWORD_PATTERN" "$FILE"
    exit 1
  fi
  
  if grep -E -q "$SSH_KEY_PATTERN" "$FILE"; then
    echo "ERROR: Potential SSH private key found in $FILE"
    grep -E --color "$SSH_KEY_PATTERN" "$FILE"
    exit 1
  fi
  
  if grep -E -q "$AWS_KEY_PATTERN" "$FILE"; then
    echo "ERROR: Potential AWS key found in $FILE"
    grep -E --color "$AWS_KEY_PATTERN" "$FILE"
    exit 1
  fi
  
  # Check for potential IP addresses (could be internal)
  IP_MATCHES=$(grep -E "$IP_PATTERN" "$FILE" || true)
  if [ -n "$IP_MATCHES" ]; then
    echo "WARNING: Potential IP address found in $FILE. Make sure this isn't sensitive information:"
    grep -E --color "$IP_PATTERN" "$FILE"
    echo "Press Enter to continue or Ctrl+C to abort the commit"
    read -r
  fi
done

echo "No sensitive data found. Proceeding with commit."
exit 0
EOF

# Make the source hook executable
chmod +x "${HOOKS_SOURCE_DIR}/pre-commit"

# Create the hooks directory if it doesn't exist
mkdir -p "${HOOK_DIR}"

# Copy the hook to the git hooks directory
cp "${HOOKS_SOURCE_DIR}/pre-commit" "${PRE_COMMIT_HOOK}"
chmod +x "${PRE_COMMIT_HOOK}"

echo "Git pre-commit hook installed successfully!"
echo "The hook will help prevent committing sensitive data."