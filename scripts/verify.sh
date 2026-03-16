#!/usr/bin/env bash
set -euo pipefail

# SuprSend Claude Code Plugin — Verify Installation

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)) || true; }

ERRORS=0
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo -e "${BOLD}SuprSend Claude Code Plugin — Verification${NC}"
echo ""

# 1. Plugin manifest
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  pass "Plugin manifest found (.claude-plugin/plugin.json)"
else
  fail "Plugin manifest missing — .claude-plugin/plugin.json not found"
fi

# 2. MCP server config
if [ -f "$PLUGIN_DIR/.mcp.json" ] && grep -q '"mcpServers"' "$PLUGIN_DIR/.mcp.json" 2>/dev/null; then
  pass "MCP server configured (.mcp.json)"
else
  fail "MCP server config missing or invalid — .mcp.json not found or malformed"
fi

# 3. Skills bundled
SKILL_COUNT=0
if [ -d "$PLUGIN_DIR/skills" ]; then
  shopt -s nullglob
  for skill_dir in "$PLUGIN_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    if [ -f "$skill_dir/SKILL.md" ]; then
      SKILL_COUNT=$((SKILL_COUNT + 1)) || true
    fi
  done
  shopt -u nullglob
fi
if [ "$SKILL_COUNT" -gt 0 ]; then
  pass "Skills bundled ($SKILL_COUNT skill(s) in skills/)"
else
  fail "No skills found — run: make build"
fi

# 4. SuprSend CLI
if command -v suprsend &>/dev/null; then
  pass "SuprSend CLI installed"
else
  fail "SuprSend CLI not found"
fi

# 5. SuprSend authentication
if [ -n "${SUPRSEND_SERVICE_TOKEN:-}" ]; then
  pass "SUPRSEND_SERVICE_TOKEN environment variable set"
elif suprsend profile list 2>/dev/null | grep -q .; then
  pass "SuprSend profile configured"
else
  fail "No SuprSend authentication found — run: suprsend profile add --name default --service-token <TOKEN>"
fi

# 6. Claude Code CLI
if command -v claude &>/dev/null; then
  pass "Claude Code CLI installed"
else
  fail "Claude Code CLI not found"
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}All checks passed!${NC} Install the plugin with: /plugin marketplace add suprsend/claude-code-plugin"
else
  echo -e "${BOLD}${RED}${ERRORS} check(s) failed.${NC} See above for fix instructions."
fi
echo ""
