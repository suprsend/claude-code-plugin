# CLAUDE.md — SuprSend Claude Code Plugin

This project is the official SuprSend plugin for Claude Code. It provides two complementary layers for working with SuprSend's notification infrastructure:

## Skills (Read-Only Context)

Skills are bundled in the `skills/` directory (fetched from `suprsend/skills` during `make build`). They give you:

- **suprsend-workflow-schema**: Complete JSON schema reference for all workflow node types, with documentation and examples.
- **suprsend-docs-support**: How to access SuprSend docs, LLM-friendly endpoints, Slack community, and support channels.
- **suprsend-cli**: Full CLI command reference for managing workspaces, templates, workflows, schemas, events, categories, and translations.

Skills load progressively — metadata at startup, instructions on activation, resources on demand.

## MCP Server (Live Platform Tools)

The SuprSend MCP server is started via the CLI:

```
suprsend start-mcp-server --transport stdio
```

It exposes tools for:

- **Workflows**: list, pull, push, enable, disable
- **Templates**: list and manage notification templates across channels
- **Schemas**: list, pull, push, commit
- **Events**: list, pull, push
- **Categories**: list, pull, push, commit
- **Translations**: list, pull, push, commit

The MCP server is configured in `.mcp.json` and auto-loads when the plugin is enabled.

The MCP server requires an authenticated SuprSend CLI. Authentication uses **service tokens** (created in [SuprSend Dashboard → Account Settings → Service Tokens](https://app.suprsend.com)).

The CLI resolves auth in priority order: (1) `SUPRSEND_SERVICE_TOKEN` env var, (2) `--service-token` flag, (3) active profile.

```
# Save a default profile
suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

## When to Use What

- **Need schema details, CLI syntax, or documentation?** → Skills handle this (no API call needed).
- **Need to list, inspect, create, or modify actual workspace resources?** → Use MCP tools.
- **Building a new workflow from scratch?** → Combine both: use the schema skill for node reference, then MCP tools to push the workflow.

## Key Commands

```bash
# Authentication
suprsend profile add --name default --service-token <TOKEN>  # Save a profile
suprsend profile list                                        # List configured profiles

# CLI essentials
suprsend sync                                            # Sync all assets
suprsend workflows list                                  # List workflows
suprsend workflows pull <slug>                           # Pull workflow locally
suprsend workflows push <slug>                           # Push workflow to platform
suprsend schemas list                                    # List schemas
suprsend schemas pull <slug>                             # Pull schema locally
suprsend schemas push <slug>                             # Push schema to platform
```

## Important Notes

- The MCP server communicates over stdio by default. SSE transport is available for remote setups.
- All MCP tools require valid authentication. If tools return auth errors, check your service token and profile configuration.
- Skills are static reference material — they don't make API calls and work offline.
- When making changes to workflows or schemas, always pull first to avoid overwriting remote changes.
