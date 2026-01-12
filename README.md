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


## How It Works

AI agents run as a dedicated `aiagents` user with no default filesystem access. You explicitly grant access to specific project directories using macOS ACLs (Access Control Lists).

## Quick Start

Follow the guides in order:

1. **[1_start.md](1_start.md)** - Create the `aiagents` user, install the ACL management script, and learn the basic workflow
2. **[2_setup_claude_code_cli.md](2_setup_claude_code_cli.md)** - Install and configure Claude Code
3. **[3_setup_codex_cli.md](3_setup_codex_cli.md)** - Install and configure OpenAI Codex CLI

## The ACL Management Tool

The `bin/ai-access` script manages directory permissions:

```bash
# Grant access to a project directory
ai-access /path/to/project grant

# Revoke access when done
ai-access /path/to/project revoke
```

## Security Model

- AI agents run as isolated user
- No access to ~/.ssh, ~/.aws, ~/.config, personal files
- Explicit permission grants via ACLs
- Revocable access
- Human approval for commands (sandbox/approval modes)

## Requirements

- macOS (uses macOS ACL system)
- Administrator access (for user creation and ACL management)
