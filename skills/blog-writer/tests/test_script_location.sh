#!/usr/bin/env bash
# Regression tests for rules/blog-writer-script-location.md.
#
# Covers the lookup contract the rule declares:
#   1. Every `bash|python3 <blog-writer-dir>/<target>` command in a skill file
#      names a target the rule lists, and the target exists in skills/blog-writer/.
#   2. Every shared reference that uses <blog-writer-dir> defines it first.
#   3. No command spells the consumer path .tessl/plugins/jbaruch/blog-writer/.
#   4. In a simulated Tessl install, the sibling lookup from another loader's
#      base directory reaches every target, and each one parses.
set -euo pipefail

cd "$(dirname "$0")/../../.."

readonly RULE=rules/blog-writer-script-location.md
readonly DEFINITION="in the commands below is blog-writer's own skill directory"
readonly TARGETS=(sweep.py check-shape-convergence.sh record-post-shape.sh
  check-catalog-version.py fetch-signs-of-ai-writing.sh setup-identity-root.py
  discover-identities.py resolve-identities.py configure-identities.py)

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# 1. Every command names a listed, existing target.
if ! commands=$(grep -rhoE '(bash|python3) <blog-writer-dir>/[A-Za-z0-9._-]+' skills --include='*.md'); then
  echo "error: no <blog-writer-dir> commands found under skills/ — the lookup the rule covers is missing" >&2
  exit 1
fi
seen=0
while IFS= read -r command; do
  target=${command##*/}
  seen=$((seen + 1))
  listed=0
  for t in "${TARGETS[@]}"; do
    if [ "$t" = "$target" ]; then listed=1; fi
  done
  if [ "$listed" -eq 0 ]; then fail "command names $target, which $RULE does not list"; fi
  if [ ! -f "skills/blog-writer/$target" ]; then fail "command names $target, which skills/blog-writer/ lacks"; fi
  case "$command" in
    "bash "*) case "$target" in *.sh) ;; *) fail "$target runs under bash but is not a .sh" ;; esac ;;
    "python3 "*) case "$target" in *.py) ;; *) fail "$target runs under python3 but is not a .py" ;; esac ;;
  esac
done <<<"$commands"
for t in "${TARGETS[@]}"; do
  if ! grep -qF "\`$t\`" "$RULE"; then fail "$RULE does not name $t"; fi
done

# 2. Every shared reference using the name defines it.
while IFS= read -r file; do
  if [ "$file" = skills/blog-writer/SKILL.md ]; then continue; fi
  if ! grep -qF "$DEFINITION" "$file"; then fail "$file uses <blog-writer-dir> without defining it"; fi
done < <(grep -rlF '<blog-writer-dir>/' skills --include='*.md')

# 3. No command spells the consumer path.
if consumer=$(grep -rnE '^(bash|python3) \.tessl/plugins/jbaruch/blog-writer/' skills --include='*.md'); then
  fail "commands still spell the consumer path: $consumer"
fi

# 4. Sibling lookup in a simulated install.
tmp=$(mktemp -d)
cleanup() {
  rm -rf "$tmp"
  return 0
}
trap cleanup EXIT
mkdir -p "$tmp/.claude/skills"
for skill in blog-writer cfp-abstract create-personal-identity create-corporate-identity; do
  ln -s "$PWD/skills/$skill" "$tmp/.claude/skills/tessl__$skill"
done
for loader in cfp-abstract create-personal-identity create-corporate-identity; do
  base="$tmp/.claude/skills/tessl__$loader"
  resolved="$(dirname "$base")/tessl__blog-writer"
  for t in "${TARGETS[@]}"; do
    path="$resolved/$t"
    if [ ! -f "$path" ]; then fail "$loader: $t not reachable at $path"; continue; fi
    case "$t" in
      *.sh) if ! bash -n "$path"; then fail "$loader: $t does not parse"; fi ;;
      *.py) if ! python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$path"; then fail "$loader: $t does not parse"; fi ;;
    esac
  done
done

echo "checked $seen command(s), ${#TARGETS[@]} target(s), 3 loader(s)"
if [ "$failures" -ne 0 ]; then
  echo "$failures failure(s)" >&2
  exit 1
fi
echo "passed: all"
