# Contributing

Thanks for your interest in improving the SuprSend Claude Code plugin! Here's how the different pieces fit together and where to contribute.

## This Repo (claude-code-plugin)

This repo is the **Claude Code plugin** — it bundles skills (from `suprsend/skills`) and configures the MCP server for Claude Code users. Contributions here are typically:

- Improving documentation (README, examples, troubleshooting)
- Enhancing setup/verify/build scripts
- Updating the `CLAUDE.md` project instructions
- Improving the plugin manifest or MCP configuration
- Adding new usage examples

### How to contribute

1. Fork the repo
2. Create a branch: `git checkout -b improve-docs`
3. Make your changes
4. Build and verify: `make setup`
5. Open a PR

## Skills (suprsend/skills)

If you want to improve the **reference content** Claude has access to (workflow schemas, CLI docs, support resources), contribute to the [skills repo](https://github.com/suprsend/skills).

Skills are generated from templates in the skills repo's `skills-src/` directory — see the [skills repo README](https://github.com/suprsend/skills) for the build pipeline and how to add or modify skills. Changes there are picked up by this plugin during `make build`.

## MCP Server (suprsend/cli)

If you want to improve the **live tools** (adding new MCP capabilities, fixing tool behavior, transport improvements), contribute to the [CLI repo](https://github.com/suprsend/cli).

The MCP server is part of the `start-mcp-server` command in the CLI.

## Reporting Issues

- **Plugin setup / integration issues** → [Open an issue here](https://github.com/suprsend/claude-code-plugin/issues)
- **Skill content is wrong or outdated** → [Open an issue on skills](https://github.com/suprsend/skills/issues)
- **MCP tool bugs or feature requests** → [Open an issue on CLI](https://github.com/suprsend/cli/issues)

## Code of Conduct

Be kind, be constructive. We're all here to make SuprSend + Claude Code better.
