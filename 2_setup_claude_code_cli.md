# Claude Code Setup for aiagents User

Instructions for installing and configuring Claude Code to run as the isolated `aiagents` user.

## Prerequisites

- `aiagents` user created and configured (see main isolation guide)
- Anthropic API key

## Installation

```bash
# Switch to aiagents user
su - aiagents

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Reload shell to use claude command
source ~/.zshrc  # or source ~/.bashrc

# Verify installation
which claude
```

## Authentication

**Store API key in Claude Code's settings file:**

```bash
# Create settings file
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": "your-anthropic-api-key-here"
  }
}
EOF

# Secure the file
chmod 600 ~/.claude/settings.json

# Verify
cat ~/.claude/settings.json
```

## Test Installation

```bash
# Test that claude runs
claude --version

# Try running claude (should not prompt for login)
claude
```

## Enable Sandbox Mode

**Once Claude Code starts, configure sandbox:**

```
/sandbox
```

**Choose:** Regular Permissions mode (NOT auto-allow)

**What sandbox mode provides:**
- ✅ Filesystem writes restricted to current working directory
- ✅ Cannot modify files outside the project
- ✅ Network traffic goes through proxy with domain allowlist
- ✅ You review EVERY command before it executes

**Sandbox modes:**
- **Regular Permissions** (recommended) - Sandbox active, you approve each command
- **Auto-allow** (NOT recommended) - Sandbox active, commands auto-execute without approval

**Why Regular Permissions mode:**
- You maintain visibility and control
- Every command requires human review
- Sandbox boundaries provide additional safety
- Prevents blind execution of AI-generated commands

**Network behavior in sandbox:**
- All network requests go through a proxy
- Proxy maintains a domain allowlist
- First request to new domain prompts for approval
- Approved domains work without prompting afterward

## Common Commands

```bash
# Check status
/status

# Enable sandbox
/sandbox

# View help
/help

# Exit
exit
```

## Troubleshooting

**Claude command not found:**
```bash
# Check if it's in ~/.local/bin
ls ~/.local/bin/claude

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Authentication fails:**
```bash
# Verify settings file exists and has correct permissions
ls -la ~/.claude/settings.json

# Check API key format (should start with sk-ant-)
cat ~/.claude/settings.json
```

**Permission errors:**
```bash
# Make sure you've granted ACL access to the project directory
# (run as your main user)
exit
ai-access /path/to/project grant
```

## Exit Back to Main User

```bash
exit
```
