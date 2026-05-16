# Standup Agent — Algorithm Overrides

## Override: Step 4 — Commit Collection

**Replace the Step 4 in the system-prompt algorithm with the following.**

Reason: `--no-merges` silently drops 2-parent GitHub merge commits, which are often the canonical "released" record for repos that use the *Create a merge commit* PR strategy. Deduplication by tree SHA is the correct way to avoid double-counting.

### Updated Step 4

For each repo dir with `$DEFAULT`:

```bash
# A. Released: hash + tree-hash from default branch
git -C "$dir" log "origin/$DEFAULT" --since="24 hours ago" \
  --pretty=format:'%H %T' 2>/dev/null | sort -u > /tmp/${repo}.released_ht.txt

# B. All commits — NO --no-merges flag
git -C "$dir" log --all --since="24 hours ago" \
  --pretty=format:'%H %T' 2>/dev/null | sort -u > /tmp/${repo}.all_ht.txt

# Build lookup files
awk '{print $1}' /tmp/${repo}.released_ht.txt | sort -u > /tmp/${repo}.released_sha.txt
awk '{print $2}' /tmp/${repo}.released_ht.txt | sort -u > /tmp/${repo}.released_trees.txt

# C. Classify with tree-SHA deduplication
while IFS=' ' read -r hash tree; do
  if grep -qx "$hash" /tmp/${repo}.released_sha.txt; then
    echo "$hash released"
  elif grep -qx "$tree" /tmp/${repo}.released_trees.txt; then
    : # Drop: in-dev commit whose filesystem state is already on the default branch
  else
    echo "$hash in-development"
  fi
done < /tmp/${repo}.all_ht.txt > /tmp/${repo}.classified.txt
```

Then collect metadata only for the commits that survived deduplication:

```bash
git -C "$dir" log --all --since="24 hours ago" \
    --pretty=format:'%H%x09%ae%x09%aN%x09%cI%x09%s%x09%D' 2>/dev/null | \
while IFS=$'\t' read -r hash email aname date subj refs; do
  status=$(awk -v h="$hash" '$1==h{print $2}' /tmp/${repo}.classified.txt)
  [ -z "$status" ] && continue   # skip deduplicated commits
  echo "$repo|$status|$hash|$email|$aname|$date|$subj|$refs"
done >> /tmp/all_commits.tsv
```

### Why this is correct

| Commit type | Parents | `--no-merges` (old) | Tree-SHA dedup (new) |
|---|---|---|---|
| Regular feature commit | 1 | kept | kept |
| GitHub squash merge to main | 1 | kept | kept (unique tree) |
| GitHub 2-parent merge to main | 2 | **dropped** | **kept** (released) |
| Feature branch commit shadowed by squash/merge | 1 or 2 | n/a | deduplicated (in-dev dropped, released kept) |
| Noisy "Merge branch X into Y" mid-branch | 2 | dropped | dropped via tree-SHA dedup (same tree as prior commit) |

## Missing Repository

`suprsend/expo-example` is not in the pre-clone list. Add it so that commits there
are captured in future runs. Until then, note in the digest:
`_(expo-example not cloned — commits there not included)_`
