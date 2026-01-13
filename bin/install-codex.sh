#!/bin/bash
set -e

# If not aiagents, create wrapper first, then switch
if [ "$(whoami)" != "aiagents" ]; then
    echo "Creating wrapper script..."
    WRAPPER_DIR="$HOME/bin"
    WRAPPER_PATH="$WRAPPER_DIR/codex"

    mkdir -p "$WRAPPER_DIR"
    cat > "$WRAPPER_PATH" << 'EOF'
#!/bin/bash
# Check if aiagents has explicit ACL permission
if ! ls -led . 2>/dev/null | grep -q "user:aiagents.*allow"; then
    echo "[ERROR] No ACL access granted for $PWD"
    echo "Run: ai-access . grant"
    exit 1
fi

# Run codex as aiagents (using zsh to respect aiagents' shell)
exec sudo -u aiagents env HOME=/Users/aiagents PWD="$PWD" zsh -c 'cd "$PWD" && exec /Users/aiagents/.npm-global/bin/codex "$@"' -- "$@"
EOF
    chmod +x "$WRAPPER_PATH"
    echo "[OK] Wrapper created at $WRAPPER_PATH"
    echo ""

    # Now switch to aiagents and run installation
    echo "Switching to aiagents user (enter aiagents password)..."
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    exec su - aiagents -c "cd '$PWD' && SKIP_WRAPPER=1 '$SCRIPT_PATH'"
fi

echo "======================================"
echo "OpenAI Codex Installation (aiagents)"
echo "======================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed"
    echo "Install Node.js first: https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "[ERROR] npm is not installed"
    exit 1
fi

echo "[OK] Node.js $(node --version)"
echo "[OK] npm $(npm --version)"
echo ""

# Check if already installed
if command -v codex &> /dev/null; then
    echo "[OK] Codex already installed"
    codex --version
    echo ""
    read -p "Reinstall? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[SKIPPED]  Skipping installation"
        exit 0
    fi
fi

# Configure npm to use user-local directory
echo "Setting up npm user-local directory..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo "[OK] npm configured for user-local installation"
echo ""

# Add to PATH for interactive shells
if ! grep -q '.npm-global/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
    echo "[OK] Added to ~/.zshrc"
fi

# Add to PATH for non-interactive shells (required for wrapper)
if ! grep -q '.npm-global/bin' ~/.zshenv 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshenv
    echo "[OK] Added to ~/.zshenv"
fi

# Reload PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# Install Codex
echo ""
echo "Installing @openai/codex..."
npm i -g @openai/codex

# Create config directory
mkdir -p ~/.codex

# Create recommended config
if [ ! -f ~/.codex/config.toml ]; then
    echo ""
    echo "Creating recommended sandbox config..."
    cat > ~/.codex/config.toml << 'EOF'
# Sandbox: restrict filesystem access
sandbox_mode = "workspace-write"

# Approval: you review commands before execution
approval_policy = "on-request"

# Network: blocked by default
[sandbox_workspace_write]
network_access = false
EOF
    echo "[OK] Config created at ~/.codex/config.toml"
else
    echo "[SKIPPED]  Config file already exists"
fi

# Verify installation
echo ""
echo "======================================"
echo "[OK] Installation Complete!"
echo "======================================"
echo ""
which codex
codex --version
echo ""
