#!/usr/bin/env bash
set -Eeuo pipefail

# classify_commits.sh
# Determines bump level (major|minor|patch|none) and lists commit messages by type
# Usage: classify_commits.sh <chart_path> <from_ref>
# Outputs: BUMP_LEVEL, HAS_COMMITS, TYPES_JSON

chart_path="${1:-}"
from_ref="${2:-}"

log_range="${from_ref}..HEAD"
commits=$(git log --no-merges --pretty=format:'%H%x09%s%x09%b' -- "${chart_path}" || true)

if [[ -n "${from_ref}" ]] && git rev-parse -q --verify "${from_ref}" > /dev/null 2>&1; then
  commits=$(git log --no-merges --pretty=format:'%H%x09%s%x09%b' "${log_range}" -- "${chart_path}" || true)
fi

if [[ -z "${commits}" ]]; then
  echo "BUMP_LEVEL=none"
  echo "HAS_COMMITS=false"
  echo "TYPES_JSON={}"
  exit 0
fi

major=false
minor=false
patch=false

feat_msgs=()
fix_msgs=()
perf_msgs=()
refactor_msgs=()
chore_msgs=()
docs_msgs=()
other_msgs=()

while IFS=$'\t' read -r sha subject body; do
  type_scope=""
  full_scope=""
  commit_regex='^(feat|fix|perf|refactor|chore|docs)(\([^)]*\))?(!)?: '
  if [[ "${subject}" =~ ${commit_regex} ]]; then
    type="${BASH_REMATCH[1]}"
    scope_with_parens="${BASH_REMATCH[2]}"
    bang="${BASH_REMATCH[3]}"
    type_scope="${type}"
    if [[ -n "${bang}" ]]; then
      type_scope+="!"
    fi
    if [[ -n "${scope_with_parens}" ]]; then
      full_scope="${scope_with_parens:1:${#scope_with_parens}-2}"
    fi
  fi
  breaking=false
  if printf '%s\n' "${subject}" | grep -q '!:'; then breaking=true; fi
  if printf '%s\n' "${body}" | grep -q 'BREAKING CHANGE:'; then breaking=true; fi
  msg="- ${subject} (${sha:0:7})"
  case "${type_scope}" in
    feat*)
      feat_msgs+=("${msg}")
      minor=true
      ;;
    fix*)
      fix_msgs+=("${msg}")
      patch=true
      ;;
    perf*)
      perf_msgs+=("${msg}")
      patch=true
      ;;
    refactor*)
      refactor_msgs+=("${msg}")
      patch=true
      ;;
    chore*)
      chore_msgs+=("${msg}")
      if [[ "${full_scope}" == "deps" ]]; then
        patch=true
      fi
      ;;
    docs*)
      docs_msgs+=("${msg}")
      ;;
    *)
      other_msgs+=("${msg}")
      patch=true
      ;;
  esac
  if ${breaking}; then major=true; fi
done <<< "${commits}"

if ${major}; then
  bump=major
elif ${minor}; then
  bump=minor
elif ${patch}; then
  bump="patch"
else
  bump=none
fi

json='{'
first=true
emit_array() {
  local name="${1}"
  shift || true
  local arr=("$@")
  [[ ${#arr[@]} -eq 0 ]] && return 0
  ${first} || json+=','
  first=false
  json+="\"${name}\":["
  local first_item=true
  for line in "${arr[@]}"; do
    line_escaped=$(printf '%s' "${line}" | sed 's/"/\\"/g')
    if ${first_item}; then
      json+="\"${line_escaped}\""
      first_item=false
    else
      json+=",\"${line_escaped}\""
    fi
  done
  json+="]"
}

emit_array feat "${feat_msgs[@]}"
emit_array fix "${fix_msgs[@]}"
emit_array perf "${perf_msgs[@]}"
emit_array refactor "${refactor_msgs[@]}"
emit_array chore "${chore_msgs[@]}"
emit_array docs "${docs_msgs[@]}"
emit_array other "${other_msgs[@]}"
json+='}'

echo "BUMP_LEVEL=${bump}"
echo "HAS_COMMITS=true"
echo "TYPES_JSON=${json}"
