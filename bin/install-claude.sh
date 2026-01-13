#!/bin/bash
set -e

# If not aiagents, create wrapper first, then switch
if [ "$(whoami)" != "aiagents" ]; then
    echo "Creating wrapper script..."
    WRAPPER_DIR="$HOME/bin"
    WRAPPER_PATH="$WRAPPER_DIR/claude"

    mkdir -p "$WRAPPER_DIR"
    cat > "$WRAPPER_PATH" << 'EOF'
#!/bin/bash
# Check if aiagents has explicit ACL permission
if ! ls -led . 2>/dev/null | grep -q "user:aiagents.*allow"; then
    echo "[ERROR] No ACL access granted for $PWD"
    echo "Run: ai-access . grant"
    exit 1
fi

# Run claude as aiagents (using zsh to respect aiagents' shell)
exec sudo -u aiagents env HOME=/Users/aiagents PWD="$PWD" zsh -c 'cd "$PWD" && exec /Users/aiagents/.local/bin/claude "$@"' -- "$@"
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
echo "Claude Code Installation (aiagents)"
echo "======================================"
echo ""

# Check if already installed
if command -v claude &> /dev/null; then
    echo "[OK] Claude Code already installed"
    claude --version
    echo ""
    read -p "Reinstall? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[SKIPPED]  Skipping installation"
        exit 0
    fi
fi

# Setup PATH first (prevents installer warning)
if ! grep -q '.local/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    echo "[OK] Added to ~/.zshrc"
fi

if ! grep -q '.local/bin' ~/.zshenv 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshenv
    echo "[OK] Added to ~/.zshenv"
fi

export PATH="$HOME/.local/bin:$PATH"

# Install Claude Code
echo "Installing Claude Code..."
# Override LOGNAME to prevent installer from using wrong home directory
LOGNAME=aiagents curl -fsSL https://claude.ai/install.sh | bash

# Create settings directory
mkdir -p ~/.claude

# Create settings.json with sandbox enabled
if [ ! -f ~/.claude/settings.json ]; then
    echo "Creating default settings with sandbox enabled..."
    cat > ~/.claude/settings.json << 'EOF'
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
EOF
    chmod 600 ~/.claude/settings.json
    echo "[OK] Settings created with sandbox enabled"
else
    echo "[SKIPPED]  Settings file already exists"
fi

# Verify installation
echo ""
echo "======================================"
echo "[OK] Installation Complete!"
echo "======================================"
echo ""
which claude
claude --version
echo ""
