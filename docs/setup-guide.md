# Setup Guide

Detailed setup instructions for each platform. The plugin runs the SuprSend CLI via `npx suprsend`, so the only hard prerequisites are **Node.js (v20+)** and **Claude Code**.

## Prerequisites (all platforms)

| Requirement     | Minimum Version | Check                |
| --------------- | --------------- | -------------------- |
| Claude Code CLI | latest          | `claude --version`   |
| Node.js + npx   | v20+            | `node --version` / `npx --version` |
| SuprSend CLI    | _optional_      | `suprsend --version` _or_ `npx suprsend --version` |

A global `suprsend` install isn't required — `npx suprsend` fetches it on first use and caches it. Installing globally (brew/Go) is supported and takes precedence over the npx fallback.

## All platforms (npx, recommended)

### 1. Authenticate

Get a service token from [Account Settings → Service Tokens](https://app.suprsend.com).

```bash
npx suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

Or set it as an environment variable for the current session:

```bash
export SUPRSEND_SERVICE_TOKEN="your_service_token_here"
```

### 2. Add the marketplace & install the plugin

Inside Claude Code:

```
/plugin marketplace add suprsend/claude-code-plugin
/plugin install suprsend@suprsend-marketplace
```

That's it. The bundled `.mcp.json` invokes `npx -y suprsend start-mcp-server`, so the MCP server starts on demand.

## Optional: global install

If you'd rather have `suprsend` on your `PATH` (faster cold starts, scripting outside the plugin):

### macOS

```bash
brew tap suprsend/tap
brew install --cask suprsend
```

### Linux / WSL (via Go)

```bash
# Install Go if needed
sudo apt update && sudo apt install -y golang-go

# Install SuprSend CLI
go install github.com/suprsend/cli/cmd/suprsend@latest

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$PATH:$(go env GOPATH)/bin"
```

### Windows (WSL)

The plugin runs best under WSL (Windows Subsystem for Linux). Follow the Linux instructions above inside your WSL environment.

```powershell
# From PowerShell, enter WSL
wsl

# Then follow Linux instructions
```

## CI/CD Environments

For automated environments where Claude Code isn't available interactively, use the SuprSend CLI directly:

```bash
# 1. Either: install CLI globally
go install github.com/suprsend/cli/cmd/suprsend@latest
# Or: invoke via npx (Node.js is usually available on CI runners)
npx -y suprsend --version

# 2. Set SUPRSEND_SERVICE_TOKEN as an encrypted secret in your CI provider

# 3. Use the CLI directly (no plugin needed)
npx suprsend workflow list
npx suprsend sync --from staging --to production
```

The MCP server and plugin are for interactive Claude Code sessions. In CI, call the SuprSend CLI commands directly.

## Uninstall

Inside Claude Code, uninstall the plugin and remove the marketplace:

```
/plugin uninstall suprsend@suprsend-marketplace
/plugin marketplace remove suprsend-marketplace
```
