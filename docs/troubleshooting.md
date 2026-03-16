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

Try removing and reinstalling the plugin inside Claude Code:

```
/plugin marketplace remove suprsend-marketplace
/plugin marketplace add suprsend/claude-code-plugin
```

### MCP server not connecting

1. Test the server standalone:
   ```bash
   suprsend start-mcp-server --transport stdio
   ```
   You should see no errors. Press Ctrl+C to stop.

2. Verify the plugin's `.mcp.json` exists and contains the suprsend server config.

3. Reinstall the plugin: `/plugin marketplace remove suprsend-marketplace` then `/plugin marketplace add suprsend/claude-code-plugin`

### Tools not appearing

If Claude doesn't seem to have access to SuprSend tools:

1. Make sure the plugin is loaded: verify with Claude that the suprsend plugin is active
2. Try explicitly asking: "Use the suprsend MCP tools to list my workflows"
3. Check that your CLI profile has the correct permissions

## Skills Issues

### Skills not activating

Skills load on demand — they activate when Claude detects you're working on SuprSend-related tasks. If skills seem missing, try reinstalling the plugin:

```
/plugin marketplace remove suprsend-marketplace
/plugin marketplace add suprsend/claude-code-plugin
```

### Stale skill content

Skills are bundled in the plugin repo. To get the latest version, reinstall the plugin — it will pull the latest from the GitHub repo.

## Environment-Specific

### CI/CD environments

For non-interactive environments, set the `SUPRSEND_SERVICE_TOKEN` environment variable. The MCP server reads from the same authentication configuration as the CLI.

## Getting Help

- [SuprSend Documentation](https://docs.suprsend.com)
- [SuprSend Slack Community](https://join.slack.com/t/suprsendcommunity/shared_invite/zt-3932rw936-XNWY1RC8bsffh4if4ZyoXQ)
- [GitHub Issues — Plugin](https://github.com/suprsend/claude-code-plugin/issues)
- [GitHub Issues — Skills](https://github.com/suprsend/skills/issues)
- [GitHub Issues — CLI](https://github.com/suprsend/cli/issues)
