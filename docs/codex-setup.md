# OpenAI Codex Setup
Codex CLI installation and configuration for aiagents user.

## Prerequisites
- Node.js installed

## Installation
```bash
./bin/install-codex.sh
```
Automatically switches to aiagents user, installs Codex, and creates wrapper script.

## Authentication
ChatGPT OAuth browser authentication should work as expected.
Or set API Key:
```bash
su - aiagents
export OPENAI_API_KEY='your-key'
echo $OPENAI_API_KEY | codex login --with-api-key
codex login status
unset OPENAI_API_KEY
chmod 600 ~/.codex/auth.json
exit
```

## Wrapper Script
Created automatically by installer at `~/bin/codex`.
Functionality:
- Checks ACL permission
- Switches to aiagents user
- Preserves working directory
- Passes through arguments

## Run
Change into your project directory.
Grant access and run codex:
```bash
  ai-access . grant
  codex
```