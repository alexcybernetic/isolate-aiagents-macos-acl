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

## Authentication & Default Sandbox Configuration

Store API key and enable sandbox by default:

```bash
# Create settings file with sandbox enabled
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": "your-anthropic-api-key-here"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true
  }
}
EOF

# Secure the file
chmod 600 ~/.claude/settings.json

# Verify
cat ~/.claude/settings.json
```

Sandbox configuration:
- `"enabled": true` - Activates filesystem and network isolation by default
- `"autoAllowBashIfSandboxed": true` - Auto-approves commands within sandbox boundaries
- Commands trying to escape sandbox still require manual approval

## Test Installation

```bash
# Test that claude runs
claude --version

# Try running claude (should not prompt for login)
claude
```

## Verify Sandbox Mode

Sandbox is now enabled by default from the settings.json configuration above.

What sandbox mode provides:
- ✅ Filesystem writes restricted to current working directory
- ✅ Cannot modify files outside the project
- ✅ Network traffic goes through proxy with domain allowlist
- ✅ Commands within sandbox boundaries auto-execute
- ✅ Commands trying to escape require manual approval

Network behavior in sandbox:
- All network requests go through a proxy
- Proxy maintains a domain allowlist
- First request to new domain prompts for approval
- Approved domains work without prompting afterward

Alternative: Change settings interactively

You can also use the `/sandbox` command in any session to change modes:

```
/sandbox
```

Available modes:
- Auto-allow - Commands within sandbox auto-execute (current config)
- Regular Permissions - Manual approval for all commands
- Off - No sandboxing

Sandbox configuration options:
- `"autoAllowBashIfSandboxed": true` - Auto-approve safe commands (recommended for isolated user)
- `"autoAllowBashIfSandboxed": false` - Manual approval for every command (more restrictive)

## Troubleshooting

Claude command not found:
```bash
# Check if it's in ~/.local/bin
ls ~/.local/bin/claude

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Authentication fails:
```bash
# Verify settings file exists and has correct permissions
ls -la ~/.claude/settings.json

# Check API key format (should start with sk-ant-)
cat ~/.claude/settings.json
```

Permission errors:
```bash
# Make sure you've granted ACL access to the project directory
# (run as your main user)
exit
ai-access /path/to/project grant
```

## Make Isolation Persistent (Optional)

To avoid manually switching to `aiagents` user every time, add an alias to your main user's shell config:

```bash
# Exit back to your main user first
exit

# Add alias to automatically run claude as aiagents user
echo 'alias claude="sudo -u aiagents -i bash -c \"cd \\\"\$PWD\\\" && claude\""' >> ~/.zshrc
source ~/.zshrc

# Or for bash:
echo 'alias claude="sudo -u aiagents -i bash -c \"cd \\\"\$PWD\\\" && claude\""' >> ~/.bashrc
source ~/.bashrc
```

Now you can run `claude` from any project directory and it will:
- Automatically switch to the `aiagents` user
- Start in your current directory
- Have sandbox mode enabled by default

Note: This requires passwordless sudo for the aiagents user (see main setup guide).

## Exit Back to Main User

```bash
exit
```
