Version 0.2
⚠️ This is an early-stage, experimental tool. Please use it only if you possess the necessary skills and knowledge to comprehend its functionality.

# AI Agents Isolation for macOS
Run AI coding agents (Claude Code, OpenAI Codex) as isolated user with ACL-based permissions.

## Overview
Agents run as dedicated `aiagents` user with explicit filesystem access via macOS ACLs. Provides least-privilege access, blast radius limitation, credential protection, and data exfiltration control.

## Security

Best practices:
- Grant ACL per project directory only
- Revoke when done: `ai-access . revoke`
- Keep sandbox enabled
- Review command approvals
- Audit permissions: `ls -led . | grep aiagents`

Passwordless sudo trade-off:
- With: convenient, but compromised account gives instant aiagents access
- Without: more secure, requires password each time

Don't grant access to:
- ~/.ssh (SSH keys)
- ~/.aws (credentials)
- ~/.config (tokens)
- ~/Documents (personal files)
- ~ (entire home directory)

## Prerequisites
- macOS with ACL support
- Administrator access
- Terminal proficiency

## Setup

### 1. Download the code

```bash
# Clone via HTTPS
git clone https://github.com/alexcybernetic/isolate-aiagents-macos-acl.git
cd isolate-aiagents-macos-acl

# Or clone via SSH
git clone git@github.com:alexcybernetic/isolate-aiagents-macos-acl.git
cd isolate-aiagents-macos-acl

# Or download ZIP and extract
# https://github.com/alexcybernetic/isolate-aiagents-macos-acl/archive/refs/heads/main.zip
```
### 2. Create aiagents User
Create standard user `aiagents` via System Settings > Users & Groups. 
Log in once to initialize, then log out and login back to your main user.

### 3. Run Setup
```bash
./bin/setup-aiagents.sh
```

Actions:
- Verifies aiagents user exists
- Prompts for optional sudoers rule (passwordless switching)
- Installs ai-access script to ~/bin
- Configures PATH in shell rc files

Passwordless sudo:
Without: password required each time (more secure)
With: no password required (convenient, less secure if account compromised)

Creates `/etc/sudoers.d/aiagents` with `username ALL=(aiagents) NOPASSWD: ALL`

### 4. Install Tools
```bash
./bin/install-claude.sh
./bin/install-codex.sh  # Requires Node.js installed
```

Installers automatically switch to aiagents user and create wrapper scripts.

See [docs/claude-setup.md](docs/claude-setup.md) and [docs/codex-setup.md](docs/codex-setup.md).

### 5. Usage

```bash
cd ~/projects/my-project
ai-access . grant
claude
```

## Access Control Commands

Grant access:
```bash
ai-access . grant
```

Revoke access:
```bash
ai-access . revoke
```

Check access:
```bash
ls -led . | grep aiagents
```
Output shows: `user:aiagents allow read,write,execute,delete...`


## Uninstall

```bash
sudo dscl . -delete /Users/aiagents
sudo rm /etc/sudoers.d/aiagents
rm ~/bin/claude ~/bin/codex ~/bin/ai-access
cd /path/to/project && ai-access . revoke  # Repeat for each granted directory
```

## License
GNU GENERAL PUBLIC LICENSE, Version 3