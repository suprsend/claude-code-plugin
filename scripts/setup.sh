#!/usr/bin/env bash
set -euo pipefail

# SuprSend Claude Code Plugin — Setup Script
# Usage: ./scripts/setup.sh

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BOLD}${GREEN}✓${NC} $1"; }
warn()  { echo -e "${BOLD}${YELLOW}⚠${NC} $1"; }
error() { echo -e "${BOLD}${RED}✗${NC} $1"; }

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo -e "${BOLD}SuprSend Claude Code Plugin — Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# -------------------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------------------

# Check git
if ! command -v git &>/dev/null; then
  error "git is required but not installed."
  exit 1
fi
info "git found"

# Check Claude Code
if ! command -v claude &>/dev/null; then
  error "Claude Code CLI is required but not installed."
  echo "  Install it from https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi
info "Claude Code CLI found"

# Check node + npx (used to run `npx suprsend`)
if ! command -v node &>/dev/null || ! command -v npx &>/dev/null; then
  error "node and npx are required but not installed."
  echo "  Install Node.js (v20+) from https://nodejs.org or via your package manager."
  echo "  The plugin runs the SuprSend CLI via 'npx suprsend' — no separate install needed."
  exit 1
fi
info "node + npx found"

# Check SuprSend CLI invocation (npx is fine — package is fetched on first use)
if command -v suprsend &>/dev/null; then
  info "SuprSend CLI on PATH"
else
  info "SuprSend CLI will run via 'npx suprsend' (no local install required)"
fi

# -------------------------------------------------------------------
# 2. Check SuprSend authentication
# -------------------------------------------------------------------

# Prefer a local CLI if one exists; fall back to npx for the profile check.
if command -v suprsend &>/dev/null; then
  SUPRSEND="suprsend"
else
  SUPRSEND="npx -y suprsend"
fi

if [ -n "${SUPRSEND_SERVICE_TOKEN:-}" ]; then
  info "SUPRSEND_SERVICE_TOKEN environment variable set"
elif $SUPRSEND profile list 2>/dev/null | grep -q .; then
  info "SuprSend profile configured"
else
  warn "No SuprSend authentication found."
  echo ""
  echo "  Get a service token from: https://app.suprsend.com (Account Settings → Service Tokens)"
  echo ""
  echo "  Then either set it as an environment variable:"
  echo ""
  echo "    export SUPRSEND_SERVICE_TOKEN=\"your_service_token_here\""
  echo ""
  echo "  Or save it as a profile:"
  echo ""
  echo "    npx suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>"
  echo ""
fi

# -------------------------------------------------------------------
# 3. Build skills
# -------------------------------------------------------------------

echo ""
"$REPO_DIR/scripts/build-skills.sh"

# -------------------------------------------------------------------
# 4. Verify
# -------------------------------------------------------------------

"$REPO_DIR/scripts/verify.sh"

# -------------------------------------------------------------------
# 5. Done
# -------------------------------------------------------------------

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}${GREEN}Setup complete!${NC}"
echo ""
echo "  Install the plugin (inside Claude Code):"
echo "    /plugin marketplace add suprsend/claude-code-plugin"
echo "    /plugin install suprsend@suprsend-marketplace"
echo ""
echo "  Then try:"
echo "    > List all my workflows"
echo "    > Show me the workflow schema for a delay node"
echo "    > What CLI commands can I use to manage templates?"
echo ""
