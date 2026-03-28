# Instructions for Cleaning Git Repository of Sensitive Information

## Prerequisites
1. Download the BFG Repo-Cleaner jar file from: https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
   (Or check the latest version at https://rtyley.github.io/bfg-repo-cleaner/)
2. Make sure you have Java installed
3. Backup your repository before proceeding!

## Step 1: Create a clone of your repository
```
git clone --mirror git://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git repo-to-clean.git
```
This creates a bare repo with just the git data.

## Step 2: Create a file with patterns of sensitive data to remove
Create a file named `sensitive-data-patterns.txt` with patterns of sensitive data to replace:

```
# SSH keys patterns
-----BEGIN.*PRIVATE KEY-----(.*?)-----END.*PRIVATE KEY-----
ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3}( .*)?

# Password/token patterns - customize based on your actual sensitive data
password\s*=\s*['"]?[A-Za-z0-9!@#$%^&*()_+]{8,}['"]?
secret\s*=\s*['"]?[A-Za-z0-9!@#$%^&*()_+]{8,}['"]?
apikey\s*=\s*['"]?[A-Za-z0-9!@#$%^&*()_+]{8,}['"]?
```

## Step 3: Clean repository using BFG
```
java -jar bfg-1.14.0.jar --replace-text sensitive-data-patterns.txt repo-to-clean.git
```

## Step 4: Remove unwanted files that were committed but are now in .gitignore
```
cd repo-to-clean.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

## Step 5: Push the cleaned repository
```
git push --force
```

## Step 6: Clean up local repositories
After you've pushed the cleaned repo, all collaborators should:
```
git fetch --all
git reset --hard origin/main  # or your default branch name
```

## IMPORTANT NOTES:
- BFG will rewrite history. All commit IDs will change.
- All repository collaborators will need to re-clone or reset their local repositories.
- If this is a public repository, inform users about the history rewrite.
- Consider disabling branch protection temporarily if it's enabled.
- After cleaning, run a security scan again to ensure all sensitive data has been removed.