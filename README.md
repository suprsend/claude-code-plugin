# SuprSend Claude Code Plugin

The official [SuprSend](https://suprsend.com) plugin for [Claude Code](https://code.claude.com/docs). Combines **bundled agent skills** and the **SuprSend MCP server** to give Claude deep context about SuprSend — workflows, templates, schemas, CLI commands, and live platform interactions — all from your terminal.

## What You Get

| Layer | What it does | Source |
|-------|-------------|--------|
| **Skills** | Workflow schema reference, CLI docs, support resources — bundled in `skills/` and loaded automatically by Claude when relevant | [`suprsend/skills`](https://github.com/suprsend/skills) |
| **MCP Server** | Live tools to query & manage your SuprSend workspace — workflows, templates, schemas, events, categories, translations | [`suprsend/cli`](https://github.com/suprsend/cli) (`start-mcp-server`) |

## Quick Start

### 1. Install the SuprSend CLI

```bash
# macOS
brew tap suprsend/tap
brew install --cask suprsend

# or via Go
go install github.com/suprsend/cli/cmd/suprsend@latest
```

### 2. Authenticate

Get a service token from your [SuprSend Dashboard → Account Settings → Service Tokens](https://app.suprsend.com), then save it as a profile:

```bash
suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>
```

Or set it as an environment variable for the current session:

```bash
export SUPRSEND_SERVICE_TOKEN="your_service_token_here"
```

### 3. Add the marketplace & install the plugin

Inside Claude Code, add the SuprSend marketplace and then install the plugin:

```
/plugin marketplace add suprsend/claude-code-plugin
/plugin install suprsend@suprsend-marketplace
```

That's it — skills and MCP tools are available immediately.

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
┌─────────────────────────────────────────────────┐
│                  Claude Code                     │
│                                                  │
│  ┌────────────────┐    ┌──────────────────────┐  │
│  │  Bundled Skills │    │    MCP Server         │  │
│  │                │    │                      │  │
│  │  • Workflow     │    │  suprsend             │  │
│  │    schema ref   │    │  start-mcp-server     │  │
│  │  • CLI docs     │    │  --transport stdio    │  │
│  │  • Support      │    │                      │  │
│  │    resources    │    │  Tools:              │  │
│  │                │    │  • Workflow mgmt      │  │
│  │  Loaded on     │    │  • Template mgmt     │  │
│  │  demand via    │    │  • Schema mgmt       │  │
│  │  progressive   │    │  • Event mgmt        │  │
│  │  disclosure    │    │  • Category mgmt     │  │
│  └────────────────┘    │  • Translation mgmt  │  │
│                        └──────────────────────┘  │
│                              │                   │
└──────────────────────────────┼───────────────────┘
                               │ stdio
                               ▼
                    ┌──────────────────┐
                    │  SuprSend API    │
                    │  (your workspace)│
                    └──────────────────┘
```

## Configuration

### MCP Server Options

The MCP server is started via the SuprSend CLI. You can pass flags to customize behavior:

```bash
# Default — stdio transport (recommended for Claude Code)
suprsend start-mcp-server

# Explicit stdio
suprsend start-mcp-server --transport stdio

# SSE transport (for remote / multi-client setups)
suprsend start-mcp-server --transport sse
```

### MCP Server Configuration

The plugin includes an `.mcp.json` that auto-registers the MCP server when the plugin is loaded. The configuration:

```json
{
  "mcpServers": {
    "suprsend": {
      "command": "suprsend",
      "args": ["start-mcp-server", "--transport", "stdio"],
      "env": {
        "SUPRSEND_SERVICE_TOKEN": "${SUPRSEND_SERVICE_TOKEN}"
      }
    }
  }
}
```

## Skills Reference

The plugin bundles three skills from [`suprsend/skills`](https://github.com/suprsend/skills) (committed to this repo, kept fresh by CI):

| Skill | Description |
|-------|-------------|
| `suprsend-workflow-schema` | Complete workflow node reference — JSON schema, documentation, and usage examples for every node type |
| `suprsend-docs-support` | How to access SuprSend documentation, LLM-friendly endpoints, in-app chat, AI copilot, Slack community, and email support |
| `suprsend-cli` | Full CLI command reference — managing workspaces, templates, workflows, schemas, and more |

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
│   │   └── SKILL.md
│   ├── suprsend-docs-support/
│   │   └── SKILL.md
│   └── suprsend-cli/
│       └── SKILL.md
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

Make sure the SuprSend CLI is installed and on your PATH:

```bash
which suprsend
# If empty, reinstall:
brew tap suprsend/tap && brew install --cask suprsend
```

### MCP server not connecting

1. Verify authentication: check your service token or profile configuration
2. Test the server manually: `suprsend start-mcp-server --transport stdio`
3. Reinstall the plugin:
   ```
   /plugin marketplace remove suprsend-marketplace
   /plugin marketplace add suprsend/claude-code-plugin
   /plugin install suprsend@suprsend-marketplace
   ```

### Skills not loading

Try removing and re-adding the plugin:

```
/plugin marketplace remove suprsend-marketplace
/plugin marketplace add suprsend/claude-code-plugin
/plugin install suprsend@suprsend-marketplace
```

### Plugin not loading

Verify the plugin is installed by checking your active plugins in Claude Code (run `/plugin` and check the **Installed** tab). If missing, reinstall:

```
/plugin marketplace add suprsend/claude-code-plugin
/plugin install suprsend@suprsend-marketplace
```

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
