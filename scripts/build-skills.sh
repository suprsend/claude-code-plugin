#!/usr/bin/env bash
set -euo pipefail

# SuprSend Claude Code Plugin — Build Skills
# Fetches compiled skills from the suprsend/skills repo.

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BOLD}${GREEN}✓${NC} $1"; }
error() { echo -e "${BOLD}${RED}✗${NC} $1"; }

SKILLS_REPO="https://github.com/suprsend/skills.git"
SKILLS_BRANCH="${SKILLS_BRANCH:-main}"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
TMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo ""
echo -e "${BOLD}SuprSend Claude Code Plugin — Build Skills${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clone the skills repo
echo -e "${BOLD}Fetching skills from suprsend/skills (branch: $SKILLS_BRANCH)...${NC}"
if git clone --depth 1 --branch "$SKILLS_BRANCH" "$SKILLS_REPO" "$TMP_DIR"; then
  info "Skills repo cloned"
else
  error "Failed to clone $SKILLS_REPO (branch: $SKILLS_BRANCH)"
  exit 1
fi

# Verify the source skills directory exists
if [ ! -d "$TMP_DIR/skills" ]; then
  error "No skills/ directory found in the repo"
  exit 1
fi

# Clean existing skills and copy new ones
rm -rf "$SKILLS_DIR"
cp -r "$TMP_DIR/skills" "$SKILLS_DIR"
info "Skills copied to $SKILLS_DIR"

# Validate each skill has a SKILL.md with required frontmatter
SKILL_COUNT=0
shopt -s nullglob
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue

  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    error "Missing SKILL.md in $skill_name"
    exit 1
  fi

  # Check for required frontmatter fields
  if ! grep -q "^name:" "$skill_file"; then
    error "Missing 'name' in frontmatter of $skill_name/SKILL.md"
    exit 1
  fi
  if ! grep -q "^description:" "$skill_file"; then
    error "Missing 'description' in frontmatter of $skill_name/SKILL.md"
    exit 1
  fi

  # Validate that name in frontmatter matches directory name
  frontmatter_name="$(grep "^name:" "$skill_file" | head -1 | sed 's/^name:[[:space:]]*//')"
  if [ "$frontmatter_name" != "$skill_name" ]; then
    error "Skill name mismatch in $skill_name/SKILL.md: frontmatter says '$frontmatter_name', directory is '$skill_name'"
    exit 1
  fi

  SKILL_COUNT=$((SKILL_COUNT + 1))
done
shopt -u nullglob

# Fail if no skills were found
if [ "$SKILL_COUNT" -eq 0 ]; then
  error "No skills found in the repo — skills/ directory is empty"
  exit 1
fi

echo ""
info "Build complete — $SKILL_COUNT skill(s) bundled"
echo ""
