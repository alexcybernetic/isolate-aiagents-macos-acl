Version 0.1

# Experimental AI Coding Agents Isolation for macOS
Run AI coding CLI tools like Claude Code, OpenAI Codex, etc. in isolation.
Isolation is essential to prevent unauthorized access to filesystem resources, limit blast radius 
from agent errors or compromise, and protect sensitive credentials (SSH keys, API tokens) from exfiltration.

## Key principles:
1. Principle of Least Privilege - agents only access what they need
2. Blast radius limitation - contains damage from bugs or LLM mistakes
3. Credential protection - prevents/control access to ~/.ssh, ~/.aws, etc.
4. Data exfiltration risk - AI agents send code to external APIs; isolation limits what can leak

## How
One shared user for all agents, ACL-controlled directory access. 

## Quick Setup

### 1. Create AI User
- System Settings → Users & Groups → Add user
- Name: **aiagents** (standard user)
- Log in as `aiagents` once, then log out

### 2. (Optional) Allow Passwordless Switching

⚠️ SECURITY TRADE-OFF:
- Without this: You type password each time you `su - aiagents` (more secure)
- With this: No password needed, but if your account is compromised, attacker gets `aiagents` access instantly

```bash
echo "$(whoami) ALL=(aiagents) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/aiagents
```

Security impact: Your main user can now run ANY command as `aiagents` without authentication. This removes a security barrier. Only do this if you prioritize convenience over defense-in-depth.

### 3. Install AI Agents

See agent-specific setup guides:
- Claude Code: [claude-code-setup.md](claude-code-setup.md)
- OpenAI Codex: [openai-codex-setup.md](openai-codex-setup.md)

Each guide covers:
- Installation as `aiagents` user
- Authentication configuration
- Sandbox/approval mode setup
- Troubleshooting

### 4. Create Helper Script for ACL Management

Create this in YOUR main user's home directory (not the `aiagents` user):

`~/bin/ai-access` - Manage directory access:
```bash
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: ai-access <directory> {grant|revoke}"
    echo "Example: ai-access . grant"
    exit 1
fi

# Resolve directory to absolute path
DIR=$(cd "$1" 2>/dev/null && pwd)

if [ -z "$DIR" ]; then
    echo "Error: Directory does not exist: $1"
    exit 1
fi

ACL="allow read,write,list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit,delete"

case "$2" in
    grant)
        echo "Granting access to: $DIR"
        sudo chmod -R +a "user:aiagents $ACL" "$DIR" || exit 1
        sudo chmod -R +a "user:$(whoami) $ACL" "$DIR" || exit 1
        echo "✅ Access granted to: $DIR"
        ;;
    revoke)
        echo "Revoking access from: $DIR"
        sudo chmod -R -a "user:aiagents" "$DIR" 2>/dev/null || true
        echo "✅ Access revoked from: $DIR"
        ;;
    *)
        echo "Error: Action must be 'grant' or 'revoke'"
        echo "Usage: ai-access <directory> {grant|revoke}"
        exit 1
        ;;
esac
```

Make executable:
```bash
chmod +x ~/bin/ai-access
```

Add ~/bin to your PATH:
```bash
# For zsh (default on modern macOS)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify it works:
```bash
which ai-access
# Should output: /Users/yourname/bin/ai-access
```

## Usage

```bash
# === Running as YOUR main user ===

# 1. Grant access to your project
cd ~/projects/my-project
ai-access . grant

# 2. Switch to aiagents user
su - aiagents
# (If you enabled passwordless: sudo -u aiagents -i)

# === Now running as aiagents user ===

# 3. Navigate to project and launch your agent
cd ~/projects/my-project

# For Claude Code:
claude

# For OpenAI Codex:
codex

# 4. Configure security settings
# See agent-specific setup guides for sandbox/approval configuration

# 5. Review EVERY command before approving

# 6. When done, exit back to your main user
exit

# === Back to YOUR main user ===

# 7. Revoke access if needed
ai-access ~/projects/my-project revoke
```

## Security Rules

### ✅ DO
- Review every command before approving
- Work in dedicated project directories

### ❌ DO NOT Grant Access To
- `~/.ssh` (SSH keys)
- `~/.aws` (credentials)  
- `~/.config` (API tokens)
- `~/Documents` (personal files)
- Your home directory

### ❌ DO NOT
- Use auto-allow mode
- Use `--dangerously-skip-permissions`
- Run as root
