# Git Repository Cleaning Instructions

## Prerequisites
1. Install git-filter-repo:
   ```
   pip install git-filter-repo
   ```

## Cleaning Steps

### 1. Create a backup of your repository
```
git clone --mirror <repository-url> repo-backup.git
```

### 2. Run git filter-repo on each branch

For each branch (main, dev, dr), follow these steps:

```bash
# Checkout the branch
git checkout <branch-name>

# Remove sensitive files
git filter-repo --path environments/dev/terraform.tfvars --path environments/prod/terraform.tfvars --path environments/dr-pilot-light/terraform.tfvars --path environments/dev/dummy_key --path environments/dev/dummy_key.pub --path environments/prod/dummy_key --path environments/prod/dummy_key.pub --path environments/dr-pilot-light/dummy_key --path environments/dr-pilot-light/dummy_key.pub --path dummy_ssh_key.pem --invert-paths --force

# Update with safe versions of files
# (Make sure your current working directory has the updated, safe versions of the files)
```

### 3. After cleaning all branches, force push to remote
```bash
git push origin --force --all
git push origin --force --tags
```

### 4. Notify all collaborators to get a fresh clone

All team members should:
```bash
# Delete their local copy
rm -rf project-repo

# Clone the clean repository
git clone <repository-url>
```

## Important Note

This process rewrites the Git history. All commits after the cleaning operation will have different hashes than before, which might cause issues with open pull requests or branches based on old commits.

Always coordinate this operation with your team and perform it at a time when there are no active development activities or open pull requests.