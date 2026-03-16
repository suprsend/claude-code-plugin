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

# Check SuprSend CLI
if ! command -v suprsend &>/dev/null; then
  warn "SuprSend CLI not found. Installing via Homebrew..."
  if command -v brew &>/dev/null; then
    if brew tap suprsend/tap && brew install suprsend; then
      info "SuprSend CLI installed"
    else
      error "Homebrew install failed."
      echo "  Install manually: https://github.com/suprsend/cli"
      exit 1
    fi
  else
    error "SuprSend CLI not found and Homebrew is not available."
    echo "  Install manually: https://github.com/suprsend/cli"
    echo "  Or via Go: go install github.com/suprsend/cli/cmd/suprsend@latest"
    exit 1
  fi
else
  info "SuprSend CLI found"
fi

# -------------------------------------------------------------------
# 2. Check SuprSend authentication
# -------------------------------------------------------------------

if [ -n "${SUPRSEND_SERVICE_TOKEN:-}" ]; then
  info "SUPRSEND_SERVICE_TOKEN environment variable set"
elif suprsend profile list 2>/dev/null | grep -q .; then
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
  echo "    suprsend profile add --name default --service-token <YOUR_SERVICE_TOKEN>"
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
echo ""
echo "  Then try:"
echo "    > List all my workflows"
echo "    > Show me the workflow schema for a delay node"
echo "    > What CLI commands can I use to manage templates?"
echo ""
