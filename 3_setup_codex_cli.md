# OpenAI Codex CLI Setup for aiagents User

Instructions for installing and configuring OpenAI Codex CLI to run as the isolated `aiagents` user.

## Prerequisites

- `aiagents` user created and configured (see main isolation guide)
- ChatGPT Plus/Pro/Team account OR OpenAI API key
- Node.js (for npm installation)

## Installation

```bash
# Switch to aiagents user
su - aiagents

# Configure npm to use user-local directory (avoids permission errors)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Add to PATH
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Now install (no sudo needed)
npm i -g @openai/codex

# Verify installation
which codex
codex --version
```

**Why user-local installation:**
- ✅ Installs in `~/.npm-global` (user-owned directory)
- ✅ No system-wide changes
- ✅ Complete isolation from main user
- ✅ No sudo/permission issues

## Authentication

### Method 1: ChatGPT OAuth (Recommended)

```bash
# Run codex to start authentication
codex

# Select "Sign in with ChatGPT"
# Browser will open for authentication
# Follow the prompts and authorize

# Return to terminal when complete
```

### Method 2: API Key

**Authenticate using API key:**

```bash
# Set API key as environment variable temporarily
export OPENAI_API_KEY="your-openai-api-key-here"

# Authenticate with Codex (stores in ~/.codex/auth.json)
echo $OPENAI_API_KEY | codex login --with-api-key

# Verify authentication
codex login status

# You can now unset the environment variable
unset OPENAI_API_KEY
```

**What this does:**
- Pipes your API key to `codex login`
- Codex stores credentials in `~/.codex/auth.json`
- Future sessions use the cached credentials
- No need to keep API key in environment permanently

**Secure the auth file:**
```bash
chmod 600 ~/.codex/auth.json
```

## Configure Sandbox Mode

**Recommended sandbox configuration for isolation:**

```bash
# Create or edit config file
cat >> ~/.codex/config.toml << 'EOF'

# Sandbox: restrict filesystem access
sandbox_mode = "workspace-write"

# Approval: you review commands before execution
approval_policy = "on-request"

# Network: blocked by default
[sandbox_workspace_write]
network_access = false
EOF
```

**Sandbox mode options:**
- `read-only` (default) - Can read files, cannot modify anything
- `workspace-write` (recommended) - Can modify workspace directory only
- `danger-full-access` (never use!) - No restrictions

**Approval policy options:**
- `untrusted` - Auto-run safe commands, prompt for risky ones
- `on-request` (recommended) - Model decides when to ask
- `on-failure` - Auto-run, prompt only on errors
- `never` (dangerous!) - No prompts

**Why these settings:**
- ✅ Can modify files in granted project directory
- ✅ Cannot modify files outside workspace
- ✅ Network blocked (enable only if needed)
- ✅ You approve sensitive operations

**Enable network if needed:**
```toml
[sandbox_workspace_write]
network_access = true  # Allow network access
```

## Test Installation

```bash
# Test that codex runs
codex --version

# Check authentication status
codex login status

# Try running codex (should not prompt for login)
codex
```

## Common Commands

```bash
# Start interactive session
codex

# Run with specific model
codex --model gpt-5-codex

# Non-interactive execution
codex exec "run tests and fix failures"

# Check status
codex /status

# Exit
/exit
```

## Troubleshooting

**Codex command not found:**
```bash
# Check npm global bin directory
npm list -g --depth=0

# Add to PATH if needed
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Authentication fails:**
```bash
# Check auth status
codex login status

# Re-authenticate
codex login

# For API key issues, verify environment variable
echo $OPENAI_API_KEY
```

**Permission errors:**
```bash
# Make sure you've granted ACL access to the project directory
# (run as your main user)
exit
ai-access /path/to/project grant
```

**Sandbox errors:**
```bash
# Check sandbox settings
cat ~/.codex/config.toml

# Verify workspace directory has proper permissions
ls -le .
```

## Configuration File Location

- Config: `~/.codex/config.toml`
- Auth: `~/.codex/auth.json`
- Logs: `~/.codex/logs/`

## Security Notes

- Codex stores credentials in `~/.codex/auth.json` (plaintext by default)
- Secure this file: `chmod 600 ~/.codex/auth.json`
- Consider using OS credential store instead (see Codex docs)
- The sandbox blocks network access by default
- Review approval mode carefully - "full-access" bypasses security

## Exit Back to Main User

```bash
exit
```
