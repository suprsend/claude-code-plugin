# Setup Guide

Detailed setup instructions for each platform.

## Prerequisites (all platforms)

| Requirement     | Minimum Version | Check                |
| --------------- | --------------- | -------------------- |
| Claude Code CLI | latest          | `claude --version`   |
| SuprSend CLI    | latest          | `suprsend --version` |

## macOS

### 1. Install SuprSend CLI

```bash
brew tap suprsend/tap
brew install suprsend
```

### 2. Authenticate

Get a service token from [Account Settings → Service Tokens](https://app.suprsend.com).

```bash
suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

### 3. Install the plugin

Inside Claude Code, run:

```
/plugin marketplace add suprsend/claude-code-plugin
```

## Linux (Debian/Ubuntu)

### 1. Install SuprSend CLI via Go

```bash
# Install Go if needed
sudo apt update && sudo apt install -y golang-go

# Install SuprSend CLI
go install github.com/suprsend/cli/cmd/suprsend@latest

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$PATH:$(go env GOPATH)/bin"
```

### 2. Authenticate

```bash
suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

### 3. Install the plugin

Inside Claude Code, run:

```
/plugin marketplace add suprsend/claude-code-plugin
```

## Windows (WSL)

The plugin runs best under WSL (Windows Subsystem for Linux). Follow the Linux instructions above inside your WSL environment.

```powershell
# From PowerShell, enter WSL
wsl

# Then follow Linux instructions
```

## CI/CD Environments

For automated environments where Claude Code isn't available interactively, use the SuprSend CLI directly:

```bash
# 1. Install CLI
go install github.com/suprsend/cli/cmd/suprsend@latest

# 2. Set SUPRSEND_SERVICE_TOKEN as an encrypted secret in your CI provider

# 3. Use the CLI directly (no plugin needed)
suprsend workflows list
suprsend sync
```

The MCP server and plugin are for interactive Claude Code sessions. In CI, call the SuprSend CLI commands directly.

## Uninstall

Inside Claude Code, run:

```
/plugin marketplace remove suprsend-marketplace
```
