#!/bin/bash
set -e

echo "======================================"
echo "AI Agents Isolation Setup"
echo "======================================"
echo ""

# Check if aiagents user exists
if id "aiagents" &>/dev/null; then
    echo "[OK] User 'aiagents' already exists"
else
    echo "[ERROR] User 'aiagents' does not exist"
    echo ""
    echo "Create standard user 'aiagents' via System Settings → Users & Groups."
    echo "Log in once to initialize, then log out and run this script again."
    exit 1
fi

# Setup sudoers for passwordless switching
echo ""
echo "[WARNING]  SECURITY TRADE-OFF:"
echo "Without sudoers rule: You type password each time (more secure)"
echo "With sudoers rule: No password needed (convenient but less secure)"
echo ""
read -p "Enable passwordless switching to aiagents? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    SUDOERS_FILE="/etc/sudoers.d/aiagents"
    if [ -f "$SUDOERS_FILE" ]; then
        echo "[OK] Sudoers rule already exists"
    else
        echo "Creating sudoers rule..."
        echo "$(whoami) ALL=(aiagents) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo -f "$SUDOERS_FILE"
        echo "[OK] Passwordless switching enabled"
    fi
else
    echo "[SKIPPED]  Skipped sudoers setup (you'll need to enter password when switching users)"
fi

# Setup ai-access script
echo ""
echo "Setting up ai-access script..."
mkdir -p ~/bin

# Copy ai-access script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ai-access" ]; then
    cp "$SCRIPT_DIR/ai-access" ~/bin/ai-access
    chmod +x ~/bin/ai-access
    echo "[OK] ai-access script installed to ~/bin/ai-access"
else
    echo "[ERROR] ai-access script not found in $SCRIPT_DIR"
    exit 1
fi

# Add ~/bin to PATH if needed
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo ""
    echo "Adding ~/bin to PATH..."

    # Detect shell
    if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
        echo "[OK] Added to ~/.zshrc"
        echo "Run: source ~/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        echo "[OK] Added to ~/.bashrc"
        echo "Run: source ~/.bashrc"
    fi
else
    echo "[OK] ~/bin already in PATH"
fi

echo ""
echo "======================================"
echo "[OK] Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Install AI tools:"
echo "   ./bin/install-claude.sh"
echo "   ./bin/install-codex.sh"
echo ""
echo "2. Grant access to your project:"
echo "   cd /path/to/your/project"
echo "   ai-access . grant"
echo ""
echo "3. Run:"
echo "   claude"
echo ""
