# CLAUDE.md — SuprSend Claude Code Plugin

This project is the official SuprSend plugin for Claude Code. It provides two complementary layers for working with SuprSend's notification infrastructure:

## Skills (Read-Only Context)

Skills are bundled in the `skills/` directory (sourced from `suprsend/skills` and committed to the repo). A CI workflow checks weekly for upstream changes and auto-opens a PR if skills drift. You can also run `make build` to refresh them manually. They give you:

- **suprsend-workflow-schema**: Complete JSON schema reference for all workflow node types, with documentation and examples.
- **suprsend-template-schema**: Template (variant) schema reference — variant envelope, multi-tenant + multi-lingual variants, Handlebars + JSONNET templating syntax, and per-channel content schemas for all 9 channels (email, sms, whatsapp, inbox, slack, ms_teams, androidpush, iospush, webpush).
- **suprsend-docs-support**: How to access SuprSend docs — docs-over-SSH (`ssh suprsend.sh`), `.md`-suffix raw markdown fallback, LLM-friendly endpoints, Slack community, and support channels.
- **suprsend-cli**: Full CLI command reference with agent-targeted per-command Tips for managing workspaces, templates, workflows, schemas, events, categories, and translations.

Skills load progressively — metadata at startup, instructions on activation, resources on demand.

## MCP Server (Live Platform Tools)

The SuprSend MCP server is started via the CLI. The bundled `.mcp.json` invokes it through `npx`, so the plugin works without a separate CLI install — Node.js v20+ is the only prerequisite:

```
npx suprsend start-mcp-server --transport stdio
```

If `suprsend` is already on `PATH` (via `brew install --cask suprsend`, `go install`, or similar), that binary is used directly and takes precedence over the npx fallback.

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
npx suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

## When to Use What

- **Need schema details, CLI syntax, or documentation?** → Skills handle this (no API call needed).
- **Need to list, inspect, create, or modify actual workspace resources?** → Use MCP tools.
- **Building a new workflow from scratch?** → Combine both: use the schema skill for node reference, then MCP tools to push the workflow.

## Key Commands

```bash
# Authentication
npx suprsend profile add --name default --service-token <TOKEN>  # Save a profile
npx suprsend profile list                                        # List configured profiles

# CLI essentials (drop the 'npx' prefix if you have a local install)
npx suprsend sync                                  # Sync all assets between workspaces
npx suprsend workflow list                         # List workflows
npx suprsend workflow pull <slug>                  # Pull workflow locally
npx suprsend workflow push <slug>                  # Push workflow to platform (writes to draft)
npx suprsend workflow commit <slug>                # Promote draft to live
npx suprsend template list                         # List templates
npx suprsend template pull <slug>                  # Pull template (including variants) locally
npx suprsend template push <slug>                  # Push template + variants (writes to draft)
npx suprsend schema list                           # List schemas
npx suprsend schema pull <slug>                    # Pull schema locally
npx suprsend schema push <slug>                    # Push schema (writes to draft)
```

## Important Notes

- The MCP server communicates over stdio by default. SSE transport is available for remote setups.
- All MCP tools require valid authentication. If tools return auth errors, check your service token and profile configuration.
- Skills are static reference material — they don't make API calls and work offline.
- When making changes to workflows or schemas, always pull first to avoid overwriting remote changes.
