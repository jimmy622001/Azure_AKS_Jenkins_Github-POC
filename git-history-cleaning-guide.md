# Comprehensive Guide for Cleaning Git History

This guide provides detailed instructions for removing sensitive information (SSH keys, passwords, etc.) from your Git repository history on all branches.

## Prerequisites

Before beginning, please:

1. **Back up your repository** - This process will rewrite Git history
2. **Coordinate with your team** - Ensure no one is making changes during this process
3. **Be in a stable environment** - Avoid interruptions during the cleaning process

## Option 1: Using BFG Repo-Cleaner (Recommended)

BFG is faster and simpler than git-filter-branch.

### Setup

1. Download BFG:
   ```
   curl -OL https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
   ```

2. Create a fresh clone for cleaning:
   ```
   git clone --mirror git://your-repo.git repo-to-clean.git
   cd repo-to-clean.git
   ```

3. Create a text file with patterns to replace (sensitive_patterns.txt):
   ```
   ssh_private_key = "-----BEGIN RSA PRIVATE KEY-----(.|\n)*?-----END RSA PRIVATE KEY-----"
   ssh_public_key = "ssh-rsa [A-Za-z0-9+/=]+"
   postgres_admin_password = "[a-zA-Z0-9!@#$%^&*()-_=+]{8,}"
   ```

### Clean the Repository

1. Run BFG:
   ```
   java -jar bfg-1.14.0.jar --replace-text sensitive_patterns.txt repo-to-clean.git
   ```

2. Update refs and clean up:
   ```
   cd repo-to-clean.git
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```

3. Review the cleaned repo:
   ```
   git log
   ```

4. Push changes:
   ```
   git push --force --all
   git push --force --tags
   ```

## Option 2: Using git-filter-repo (Modern Alternative)

Git-filter-repo is the modern replacement for git-filter-branch.

### Setup

1. Install git-filter-repo:
   ```
   pip install git-filter-repo
   ```

2. Create a fresh clone:
   ```
   git clone your-repo.git clean-repo
   cd clean-repo
   ```

### Clean the Repository

1. Run for each branch:
   ```
   git checkout main
   git filter-repo --path-glob "**/terraform.tfvars" --path-glob "**/dummy_key*" --path dummy_ssh_key.pem --invert-paths --force
   
   git checkout dev
   git filter-repo --path-glob "**/terraform.tfvars" --path-glob "**/dummy_key*" --path dummy_ssh_key.pem --invert-paths --force
   
   git checkout dr
   git filter-repo --path-glob "**/terraform.tfvars" --path-glob "**/dummy_key*" --path dummy_ssh_key.pem --invert-paths --force
   ```

2. Push changes:
   ```
   git push --force --all
   git push --force --tags
   ```

## Option 3: Windows-specific Approach

For Windows environments, use this batch script approach:

1. Use the provided `windows-cleanup-script.bat` file
2. Run the script from your repository root
3. Follow the on-screen instructions

## After Cleaning

1. **All team members** should:
   ```
   # Delete old local copy
   rm -rf project-repo
   
   # Clone fresh copy
   git clone project-url
   ```

2. **Replace sensitive files** with placeholder files as previously done
3. **Update .gitignore** to prevent future commits of sensitive files
4. **Rotate any real credentials** that might have been exposed

## Troubleshooting

- **Timeout issues**: If operations time out, try running on a machine with more resources
- **Permission denied**: Make sure you have write access to the repository
- **Merge conflicts**: After cleaning, any branches based on old history may have conflicts when merged

## References

- [BFG Repo-Cleaner Documentation](https://rtyley.github.io/bfg-repo-cleaner/)
- [Git-filter-repo Documentation](https://github.com/newren/git-filter-repo)
- [GitHub Help: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)