#!/usr/bin/env bash
# Regression tests for rules/blog-writer-script-location.md.
#
# Covers the lookup contract the rule declares:
#   1. Every `bash|python3 <blog-writer-dir>/<target>` command in a skill file
#      names a target the rule lists, and the target exists in skills/blog-writer/.
#   2. Every file that uses <blog-writer-dir> defines it above its first command.
#   3. No command spells the consumer path .tessl/plugins/jbaruch/blog-writer/.
#   4. In a simulated Tessl install, the sibling lookup from another loader's
#      base directory reaches every target, and each one parses.
set -euo pipefail

cd "$(dirname "$0")/../../.."

readonly RULE=rules/blog-writer-script-location.md
readonly REFERENCE_DEFINITION="in the commands below is blog-writer's own skill directory"
readonly SKILL_DEFINITION="in every command is this skill's base directory"
readonly COMMAND_RE='(bash|python3) <blog-writer-dir>/[A-Za-z0-9._-]+'
readonly TARGETS=(sweep.py check-shape-convergence.sh record-post-shape.sh
  check-catalog-version.py fetch-signs-of-ai-writing.sh setup-identity-root.py
  discover-identities.py resolve-identities.py configure-identities.py)

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# grep exits 1 on no match and 2 on a tool error; only the first is an
# answer. GREP_OUT holds the matches.
GREP_OUT=''
run_grep() {
  local status=0
  GREP_OUT=$(grep "$@") || status=$?
  case "$status" in
    0 | 1) return 0 ;;
    *)
      echo "error: grep failed (exit ${status}) for: grep $* — check the skills/ tree is readable" >&2
      exit 2
      ;;
  esac
}

# 1. Every command names a listed, existing target.
run_grep -rhoE "$COMMAND_RE" skills --include='*.md'
if [ -z "$GREP_OUT" ]; then
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
done <<<"$GREP_OUT"
for t in "${TARGETS[@]}"; do
  run_grep -cF "\`$t\`" "$RULE"
  if [ "${GREP_OUT:-0}" = 0 ]; then fail "$RULE does not name $t"; fi
done

# 2. Every file using the name defines it above its first command.
run_grep -rlE "$COMMAND_RE" skills --include='*.md'
files=$GREP_OUT
while IFS= read -r file; do
  definition=$REFERENCE_DEFINITION
  if [ "$file" = skills/blog-writer/SKILL.md ]; then definition=$SKILL_DEFINITION; fi
  run_grep -nF "$definition" "$file"
  defined_at=${GREP_OUT%%:*}
  run_grep -nE "$COMMAND_RE" "$file"
  first_command_at=${GREP_OUT%%:*}
  if [ -z "$defined_at" ]; then
    fail "$file uses <blog-writer-dir> without defining it"
  elif [ "$defined_at" -ge "$first_command_at" ]; then
    fail "$file defines <blog-writer-dir> on line $defined_at, after its first command on line $first_command_at"
  fi
done <<<"$files"

# 3. No command spells the consumer path.
run_grep -rnE '^(bash|python3) \.tessl/plugins/jbaruch/blog-writer/' skills --include='*.md'
if [ -n "$GREP_OUT" ]; then fail "commands still spell the consumer path: $GREP_OUT"; fi

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
    if [ ! -f "$path" ]; then
      fail "$loader: $t not reachable at $path"
      continue
    fi
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
