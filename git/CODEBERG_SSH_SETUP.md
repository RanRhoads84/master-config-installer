# Codeberg SSH Key Setup Guide

Complete guide for setting up SSH keys for Codeberg (and GitHub) authentication.

## Quick Reference

Your current setup uses:
- **Key**: `~/.ssh/id_ed25519` for Codeberg
- **Algorithm**: Ed25519 (modern, secure, recommended)
- **Git config**: Auto-converts HTTPS URLs to SSH
- **SSH config**: Routes Codeberg traffic through correct key

## Creating SSH Keys for Codeberg

### Step 1: Generate SSH Key

Generate a new Ed25519 SSH key pair:

```bash
ssh-keygen -t ed25519 -C "jag@justaguylinux.com" -f ~/.ssh/id_ed25519_codeberg
```

**Options explained:**
- `-t ed25519` - Use Ed25519 algorithm (faster, more secure than RSA)
- `-C "email"` - Comment to identify the key
- `-f ~/.ssh/id_ed25519_codeberg` - Output file path

When prompted:
1. **Passphrase**: Press Enter for no passphrase (convenient) or enter one (more secure)
2. Confirm passphrase

This creates two files:
- `~/.ssh/id_ed25519_codeberg` - Private key (keep secret!)
- `~/.ssh/id_ed25519_codeberg.pub` - Public key (share with Codeberg)

### Step 2: Add Key to SSH Agent (Optional)

If you set a passphrase, add the key to ssh-agent to avoid repeated prompts:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_codeberg
```

### Step 3: Copy Public Key

Display your public key:

```bash
cat ~/.ssh/id_ed25519_codeberg.pub
```

Copy the entire output (starts with `ssh-ed25519` and ends with your email).

**Quick copy to clipboard:**
```bash
# Using xclip (X11)
cat ~/.ssh/id_ed25519_codeberg.pub | xclip -selection clipboard

# Using wl-copy (Wayland)
cat ~/.ssh/id_ed25519_codeberg.pub | wl-copy
```

### Step 4: Add Key to Codeberg

1. Log into Codeberg: https://codeberg.org
2. Go to **Settings** → **SSH / GPG Keys**
3. Click **Add Key**
4. Paste your public key
5. Give it a descriptive name (e.g., "Debian Laptop - Nov 2024")
6. Click **Add Key**

### Step 5: Configure SSH

Create or edit `~/.ssh/config`:

```bash
nano ~/.ssh/config
```

Add this configuration:

```
Host codeberg.org
    HostName codeberg.org
    User git
    IdentityFile ~/.ssh/id_ed25519_codeberg
    IdentitiesOnly yes
```

**Explanation:**
- `Host codeberg.org` - Applies settings when connecting to codeberg.org
- `User git` - Always use 'git' as username
- `IdentityFile` - Path to your private key
- `IdentitiesOnly yes` - Only use specified key (prevents SSH from trying all keys)

### Step 6: Configure Git URL Rewriting (Optional but Recommended)

This automatically converts HTTPS URLs to SSH, so you never have to type passwords:

```bash
git config --global url."git@codeberg.org:".insteadOf "https://codeberg.org/"
```

Now when you clone:
```bash
git clone https://codeberg.org/user/repo.git
```

Git automatically uses:
```bash
git clone git@codeberg.org:user/repo.git
```

### Step 7: Test Connection

Verify your SSH key works:

```bash
ssh -T git@codeberg.org
```

Expected output:
```
Hi <username>! You've successfully authenticated, but Codeberg does not provide shell access.
```

If you see this, you're all set!

## Managing Multiple Git Accounts

Your setup supports both Codeberg and GitHub with separate keys:

### GitHub Configuration

```bash
# Generate GitHub key
ssh-keygen -t ed25519 -C "jag@justaguylinux.com" -f ~/.ssh/id_ed25519_github

# Add to ~/.ssh/config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

# Configure git URL rewriting
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Test connection
ssh -T git@github.com
```

## Using With Your gitup Script

Your `gitup` script works perfectly with SSH keys:

```bash
# In any git repository
gitup
```

The script will:
1. Show changed files
2. Prompt for commit message
3. Execute: `git add -A && git commit -m "$msg" && git push`
4. Push uses SSH automatically (no password needed!)

## Troubleshooting

### Permission Denied (publickey)

**Problem:** `Permission denied (publickey)`

**Solutions:**
```bash
# Check SSH config syntax
cat ~/.ssh/config

# Verify key permissions (must be 600)
chmod 600 ~/.ssh/id_ed25519_codeberg
chmod 644 ~/.ssh/id_ed25519_codeberg.pub

# Test with verbose output
ssh -vT git@codeberg.org

# Verify key is loaded
ssh-add -l
```

### Wrong Key Being Used

**Problem:** SSH tries wrong key first

**Solution:**
```bash
# Add to ~/.ssh/config for the host
IdentitiesOnly yes
```

### Could not open a connection to your authentication agent

**Problem:** ssh-agent not running

**Solution:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_codeberg
```

### Key Fingerprint Verification

First time connecting, verify fingerprint matches Codeberg's official fingerprints:

**Codeberg SSH Fingerprints:**
- Ed25519: `SHA256:1F1oQeSZCx2taLPAYX+0hu6wFbNPIdY+ZNXHvEFkIjw`

## Best Practices

### Security
- ✅ Use Ed25519 keys (faster, more secure than RSA)
- ✅ Use separate keys for different services
- ✅ Set proper permissions: `chmod 600 ~/.ssh/id_ed25519*`
- ✅ Add passphrase to keys (optional but recommended)
- ❌ Never share your private key (files without .pub)
- ❌ Never commit keys to git repositories

### Key Management
```bash
# List all your public keys
ls -l ~/.ssh/*.pub

# Show fingerprint of a key
ssh-keygen -lf ~/.ssh/id_ed25519_codeberg.pub

# Remove a key from ssh-agent
ssh-add -d ~/.ssh/id_ed25519_codeberg

# List keys in ssh-agent
ssh-add -l
```

### Backup Your Keys
```bash
# Backup to encrypted storage
cp -r ~/.ssh ~/backups/ssh-keys-$(date +%Y%m%d)
chmod -R 600 ~/backups/ssh-keys-*
```

## Your Current Git Configuration

From `~/.gitconfig`:
```ini
[url "git@codeberg.org:"]
    insteadOf = https://codeberg.org/
[url "git@github.com:"]
    insteadOf = https://github.com/
[user]
    name = Drew
    email = jag@justaguylinux.com
```

This setup means:
- All Codeberg/GitHub operations use SSH automatically
- No password prompts
- Works seamlessly with `gitup` and `git-sync`
- Can push/pull without authentication prompts

## Quick Commands Reference

```bash
# Generate new key
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519_service

# Copy public key to clipboard
cat ~/.ssh/id_ed25519_codeberg.pub | xclip -selection clipboard

# Test connection
ssh -T git@codeberg.org

# Check SSH config
cat ~/.ssh/config

# Verify key permissions
ls -l ~/.ssh/id_ed25519*

# Clone with SSH (auto-converted from HTTPS)
git clone https://codeberg.org/user/repo.git

# Use with gitup
cd /path/to/repo && gitup
```

## Additional Resources

- Codeberg SSH Keys: https://docs.codeberg.org/security/ssh-key/
- Ed25519 Info: https://ed25519.cr.yp.to/
- SSH Config Man Page: `man ssh_config`
- GitHub SSH Guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

---

**Note:** This guide is based on your actual working configuration. Your system already has this setup working perfectly!
