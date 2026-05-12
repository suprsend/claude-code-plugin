# SuprSend Claude Code Plugin

The official [SuprSend](https://suprsend.com) plugin for [Claude Code](https://code.claude.com/docs). Combines **bundled agent skills** and the **SuprSend MCP server** to give Claude deep context about SuprSend — workflows, templates, schemas, CLI commands, and live platform interactions — all from your terminal.

## What You Get

| Layer | What it does | Source |
|-------|-------------|--------|
| **Skills** | Workflow schema, template (variant) schema, CLI docs, support resources — bundled in `skills/` and loaded automatically by Claude when relevant | [`suprsend/skills`](https://github.com/suprsend/skills) |
| **MCP Server** | Live tools to query & manage your SuprSend workspace — workflows, templates, schemas, events, categories, translations | [`suprsend/cli`](https://github.com/suprsend/cli) (`start-mcp-server`) |

## Quick Start

The plugin format is shared across **Claude Code**, **VS Code Copilot**, and **GitHub Copilot CLI** — the same repo serves all three. The plugin runs the SuprSend CLI via `npx suprsend`, so the only hard prerequisite is Node.js (v20+).

### 1. Authenticate

Get a service token from your [SuprSend Dashboard → Account Settings → Service Tokens](https://app.suprsend.com), then save it as a profile:

```bash
npx suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

Or set it as an environment variable for the current session:

```bash
export SUPRSEND_SERVICE_TOKEN="your_service_token_here"
```

### 2. Install the plugin

#### Claude Code

Inside Claude Code, add the SuprSend marketplace and then install the plugin:

```
/plugin marketplace add suprsend/claude-code-plugin
/plugin install suprsend@suprsend-marketplace
```

#### VS Code Copilot

1. Open the command palette (`Cmd/Ctrl + Shift + P`)
2. Run **`Chat: Install Plugin From Source`**
3. Enter `suprsend/claude-code-plugin` when prompted (or the full URL `https://github.com/suprsend/claude-code-plugin.git`)

Verify the plugin is enabled in the Extensions sidebar under **Agent Plugins → Installed** (search `@agentPlugins`), or open the Chat view's gear → **Plugins**.

For a whole team, commit `.github/copilot/settings.json` to your project repo:

```json
{
  "extraKnownMarketplaces": {
    "suprsend-marketplace": {
      "source": { "source": "github", "repo": "suprsend/claude-code-plugin" }
    }
  },
  "enabledPlugins": {
    "suprsend@suprsend-marketplace": true
  }
}
```

When teammates open the repo, the marketplace is auto-registered and the plugin is enabled.

---

That's it — skills and MCP tools are available immediately. The host tool fetches the `suprsend` npm package on first MCP startup and caches it; subsequent launches are instant.

> Prefer a global install? `brew tap suprsend/tap && brew install --cask suprsend` (macOS) or `go install github.com/suprsend/cli/cmd/suprsend@latest` (any platform) both work — `suprsend` on `PATH` takes precedence over the npx fallback.

## Usage Examples

Once loaded, just talk to Claude naturally:

```
> List all my workflows

> Create a new workflow called "welcome-email" that sends an email
  when a user signs up

> Show me the schema for workflow nodes

> Pull the "order-confirmed" workflow and explain what it does

> What CLI commands can I use to manage templates?

> Push my local workflow changes to staging

> Show me how to configure a fallback from email to SMS
```

Claude will automatically activate the right skills and MCP tools based on your request.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Claude Code                       │
│                                                      │
│  ┌──────────────────┐    ┌──────────────────────┐    │
│  │  Bundled Skills  │    │     MCP Server       │    │
│  │                  │    │                      │    │
│  │  • Workflow      │    │  npx suprsend        │    │
│  │    schema ref    │    │  start-mcp-server    │    │
│  │  • Template      │    │  --transport stdio   │    │
│  │    (variant)     │    │                      │    │
│  │    schema ref    │    │  Tools:              │    │
│  │  • CLI docs      │    │  • Workflow mgmt     │    │
│  │  • Support       │    │  • Template mgmt     │    │
│  │    resources     │    │  • Schema mgmt       │    │
│  │                  │    │  • Event mgmt        │    │
│  │  Loaded on       │    │  • Category mgmt     │    │
│  │  demand via      │    │  • Translation mgmt  │    │
│  │  progressive     │    │                      │    │
│  │  disclosure      │    │                      │    │
│  └──────────────────┘    └──────────────────────┘    │
│                                  │                   │
└──────────────────────────────────┼───────────────────┘
                                   │ stdio
                                   ▼
                        ┌──────────────────┐
                        │  SuprSend API    │
                        │  (your workspace)│
                        └──────────────────┘
```

## Configuration

### MCP Server Options

The MCP server is started via the SuprSend CLI. You can pass flags to customize behavior (use `suprsend` if installed globally, or `npx suprsend` otherwise):

```bash
# Default — stdio transport (recommended for Claude Code)
npx suprsend start-mcp-server

# Explicit stdio
npx suprsend start-mcp-server --transport stdio

# SSE transport (for remote / multi-client setups)
npx suprsend start-mcp-server --transport sse
```

### MCP Server Configuration

The plugin includes an `.mcp.json` that auto-registers the MCP server when the plugin is loaded. The configuration:

```json
{
  "mcpServers": {
    "suprsend": {
      "command": "npx",
      "args": ["-y", "suprsend", "start-mcp-server", "--transport", "stdio"]
    }
  }
}
```

`npx -y` fetches the `suprsend` npm package on first launch and caches it for subsequent runs. The CLI reads `SUPRSEND_SERVICE_TOKEN` from the environment, or falls back to the active profile (see Authentication above).

## Skills Reference

The plugin bundles four skills from [`suprsend/skills`](https://github.com/suprsend/skills) (committed to this repo, kept fresh by CI):

| Skill | Description |
|-------|-------------|
| `suprsend-workflow-schema` | Complete workflow node reference — JSON schema, documentation, and usage examples for every node type |
| `suprsend-template-schema` | Template (variant) schema reference — variant envelope, multi-tenant & multi-lingual variants, Handlebars + JSONNET syntax, and per-channel content schemas for all 9 channels (email, sms, whatsapp, inbox, slack, ms_teams, androidpush, iospush, webpush) |
| `suprsend-docs-support` | How to access SuprSend documentation — docs-over-SSH (`ssh suprsend.sh`), `.md`-suffix raw markdown fallback, LLM-friendly endpoints, in-app chat, AI copilot, Slack community, and email support |
| `suprsend-cli` | Full CLI command reference with agent-targeted per-command Tips — managing workspaces, templates, workflows, schemas, and more |

Skills follow the [agentskills.io progressive disclosure](https://agentskills.io/specification) model: metadata loads at startup, instructions load on activation, and resources load on demand.

## MCP Tools Reference

The MCP server exposes tools across these categories:

### Workflow Management
- List, pull, push, enable, and disable workflows
- Inspect workflow configuration and node structure

### Template Management
- List and manage notification templates across channels

### Schema Management
- List, pull, push, and commit schemas
- Validate workflow payloads against schemas

### Event Management
- List, pull, and push events
- Inspect event definitions and properties

### Category Management
- List, pull, push, and commit categories

### Translation Management
- List, pull, push, and commit translations

## Project Structure

```
claude-code-plugin/
├── .claude-plugin/
│   ├── marketplace.json   # Marketplace manifest (for /plugin marketplace add)
│   └── plugin.json        # Plugin manifest
├── .mcp.json              # MCP server configuration (auto-loaded by plugin)
├── .gitignore             # Excludes .env, OS files
├── CLAUDE.md              # Claude Code project instructions
├── CONTRIBUTING.md        # Contribution guidelines
├── LICENSE                # MIT license
├── Makefile               # build, clean, setup, verify targets
├── README.md              # This file
├── SECURITY.md            # Security policy and credential handling
├── skills/                # Bundled skills (sourced from suprsend/skills, committed)
│   ├── suprsend-workflow-schema/
│   ├── suprsend-template-schema/
│   ├── suprsend-docs-support/
│   └── suprsend-cli/
├── docs/
│   ├── examples.md        # Extended usage examples
│   ├── setup-guide.md     # Platform-specific setup instructions
│   └── troubleshooting.md # Common issues & fixes
└── scripts/
    ├── build-skills.sh    # Fetches skills from suprsend/skills repo
    ├── setup.sh           # Full setup (prerequisites + build + verify)
    └── verify.sh          # Verify plugin installation
```

## Development

```bash
# Build skills from suprsend/skills repo
make build

# Build from a specific branch
SKILLS_BRANCH=staging make build

# Clean built skills
make clean

# Full setup (prerequisites + build + verify)
make setup

# Verify installation
make verify
```

## Troubleshooting

### "suprsend: command not found"

The plugin uses `npx suprsend` by default, so you only need Node.js (v20+). If `node` and `npx` are present, the MCP server fetches the SuprSend CLI on first launch — no manual install needed:

```bash
node --version   # should print v20.x or newer
npx --version
```

If you prefer a global install, either of these works (and takes precedence over the npx fallback):

```bash
brew tap suprsend/tap && brew install --cask suprsend         # macOS
go install github.com/suprsend/cli/cmd/suprsend@latest        # any platform
```

### MCP server not connecting

1. Verify authentication: check your service token or profile configuration
2. Test the server manually: `npx suprsend start-mcp-server --transport stdio`
3. Reinstall the plugin:
   - **Claude Code**:
     ```
     /plugin marketplace remove suprsend-marketplace
     /plugin marketplace add suprsend/claude-code-plugin
     /plugin install suprsend@suprsend-marketplace
     ```
   - **VS Code Copilot**: right-click the `suprsend` plugin in **Agent Plugins → Installed** → **Uninstall**, then run `Chat: Install Plugin From Source` again.

In VS Code, MCP startup logs appear in the **Output** panel (pick **MCP — suprsend** from the dropdown).

### Skills not loading

Try removing and re-adding the plugin:

- **Claude Code**:
  ```
  /plugin marketplace remove suprsend-marketplace
  /plugin marketplace add suprsend/claude-code-plugin
  /plugin install suprsend@suprsend-marketplace
  ```
- **VS Code Copilot**: toggle the plugin off and on in **Agent Plugins → Installed**, or uninstall and reinstall via the command palette.

### Plugin not loading

- **Claude Code**: run `/plugin` and check the **Installed** tab. If missing, reinstall via `/plugin marketplace add suprsend/claude-code-plugin`.
- **VS Code Copilot**: search `@agentPlugins` in the Extensions sidebar. If missing, reinstall via `Chat: Install Plugin From Source`.

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details on improving this plugin (docs, scripts, setup). For skills content, see the [skills repo](https://github.com/suprsend/skills). For MCP server improvements, see the [CLI repo](https://github.com/suprsend/cli).

## Links

- [SuprSend Documentation](https://docs.suprsend.com)
- [SuprSend CLI Reference](https://docs.suprsend.com/reference/cli-intro)
- [SuprSend Skills](https://github.com/suprsend/skills)
- [SuprSend CLI](https://github.com/suprsend/cli)
- [MCP Server Docs](https://github.com/suprsend/cli/blob/main/docs/suprsend_start-mcp-server.md)
- [Agent Skills Specification](https://agentskills.io/specification)
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins)

## License

MIT
