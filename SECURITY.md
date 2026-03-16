# Security

## Reporting Vulnerabilities

If you discover a security vulnerability in this plugin, **please do not open a public issue**. Instead, email [security@suprsend.com](mailto:security@suprsend.com) with details.

We'll acknowledge your report within 48 hours and work with you to resolve it.

## Security Considerations

### Service Tokens

Authentication uses **service tokens** created in [Account Settings → Service Tokens](https://app.suprsend.com). Tokens stored in profiles are kept locally by the CLI in your home directory. They are **never** committed to this repo — the `.gitignore` excludes all `.env` files.

- Never hardcode tokens in `.mcp.json` or any checked-in file
- Prefer **environment variables or profiles** over `--service-token` flags, since flags can appear in shell history or process listings
- Use `suprsend profile add --name default --service-token <TOKEN>` to store tokens securely via the CLI
- Rotate service tokens regularly via the [SuprSend Dashboard](https://app.suprsend.com) and follow the principle of least privilege

### MCP Server Transport

- **stdio** (default): Communication happens over local process stdin/stdout. No network exposure.
- **SSE**: Opens a local HTTP endpoint. Only use this in trusted network environments.

### Skills

Skills are read-only reference material. They do not make API calls, store credentials, or execute code against your workspace.

Skills are fetched from the [`suprsend/skills`](https://github.com/suprsend/skills) repo during `make build`. The build always fetches the latest `main` branch by default. To pin to a specific version, set `SKILLS_BRANCH` to a tag or commit reference:

```bash
SKILLS_BRANCH=v1.0.0 make build
```
