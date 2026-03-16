# Troubleshooting

## CLI Issues

### "suprsend: command not found"

The SuprSend CLI isn't on your PATH.

**Fix (macOS):**
```bash
brew tap suprsend/tap && brew install suprsend
```

**Fix (Go):**
```bash
go install github.com/suprsend/cli/cmd/suprsend@latest
# Ensure $GOPATH/bin is in your PATH
```

### Authentication errors

MCP tools return 401 or "unauthorized" errors.

**Fix:**

The CLI resolves authentication in this priority order: (1) `SUPRSEND_SERVICE_TOKEN` env var, (2) `--service-token` flag, (3) active profile.

```bash
# Option 1: Set environment variable
export SUPRSEND_SERVICE_TOKEN="your_service_token_here"

# Option 2: Add or re-add a profile
suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

Get a new service token from [Account Settings → Service Tokens](https://app.suprsend.com) if needed.

## Plugin Issues

### Plugin not loading

Verify the plugin structure is intact:

```bash
make verify
```

All checks should pass. If skills are missing, rebuild them:

```bash
make build
```

Then load the plugin:

```bash
claude --plugin-dir .
```

### MCP server not connecting

1. Test the server standalone:
   ```bash
   suprsend start-mcp-server --transport stdio
   ```
   You should see no errors. Press Ctrl+C to stop.

2. Verify the plugin's `.mcp.json` exists and contains the suprsend server config.

3. Reload the plugin in Claude Code.

### Tools not appearing

If Claude doesn't seem to have access to SuprSend tools:

1. Make sure the plugin is loaded: verify with Claude that the suprsend plugin is active
2. Try explicitly asking: "Use the suprsend MCP tools to list my workflows"
3. Check that your CLI profile has the correct permissions

## Skills Issues

### Skills not activating

Skills load on demand — they activate when Claude detects you're working on SuprSend-related tasks.

**Rebuild skills:**
```bash
make clean && make build
```

### Stale skill content

Skills are fetched from the `suprsend/skills` repo during build. To get the latest:

```bash
make clean && make build
```

## Environment-Specific

### CI/CD environments

For non-interactive environments, set the `SUPRSEND_SERVICE_TOKEN` environment variable. The MCP server reads from the same authentication configuration as the CLI.

## Getting Help

- [SuprSend Documentation](https://docs.suprsend.com)
- [SuprSend Slack Community](https://join.slack.com/t/suprsendcommunity/shared_invite/zt-3932rw936-XNWY1RC8bsffh4if4ZyoXQ)
- [GitHub Issues — Plugin](https://github.com/suprsend/claude-code-plugin/issues)
- [GitHub Issues — Skills](https://github.com/suprsend/skills/issues)
- [GitHub Issues — CLI](https://github.com/suprsend/cli/issues)
