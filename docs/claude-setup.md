# Claude Code Setup
Claude Code installation and configuration for aiagents user.

## Installation
```bash
./bin/install-claude.sh
```
Automatically switches to aiagents user, installs Claude Code, and creates wrapper script.

## Authentication
Claude Code browser authentication should work as expected.
Or set API key via dialog or the configuration file (next section).

## Configuration
Location: `/Users/aiagents/.claude/settings.json`
```json
{
  "env": {
    "ANTHROPIC_API_KEY": "YOUR_KEY"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

Settings:
- `enabled: true` - Filesystem/network isolation
- `autoAllowBashIfSandboxed: false` - Manual command approval
- `autoAllowBashIfSandboxed: true` - Auto-approve sandboxed commands

Permissions: `chmod 600 ~/.claude/settings.json`

## Sandbox Behavior
Filesystem:
- Writes restricted to working directory
- Cannot modify outside project
- Escape attempts require approval

Network:
- Proxied through domain allowlist
- First request to domain requires approval
- Approved domains cached


## Wrapper Script
Created automatically by installer at `~/bin/claude`.
Functionality:
- Checks ACL permission
- Switches to aiagents user
- Preserves working directory
- Passes through arguments\

## Run
Change into your project directory.
Grant access and run claude:
```bash
  ai-access . grant
  claude
```

