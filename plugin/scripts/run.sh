#!/bin/bash
# wa-mirror MCP launcher (spec §14.4). stdout is the MCP protocol: every message here goes to
# stderr. The repository is the script-relative one (<repo>/plugin/scripts/run.sh) when it is
# the wa-mirror project with a .venv; otherwise the absolute path in <data_dir>/repo_path,
# which `wamirror init` writes. That one file is all this script reads from the data dir.
set -euo pipefail

log() { printf 'wa-mirror: %s\n' "$*" >&2; }
fail() {
  log "$1; run: uv sync --frozen, then wamirror init"
  exit 1
}

# A usable repo: the wa-mirror project (pyproject name) with a synced .venv.
usable() {
  [ -f "$1/pyproject.toml" ] && [ -d "$1/.venv" ] \
    && grep -Eq '^name = "wa-mirror"$' "$1/pyproject.toml"
}

uv=""
for candidate in "$HOME/.local/bin/uv" /opt/homebrew/bin/uv; do
  if [ -x "$candidate" ]; then
    uv="$candidate"
    break
  fi
done
if [ -z "$uv" ]; then
  log "uv not found at ~/.local/bin/uv or /opt/homebrew/bin/uv; install uv first"
  exit 1
fi

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo="$(cd "$here/../.." && pwd -P)"
if ! usable "$repo"; then
  data_dir="${WAMIRROR_DATA_DIR:-$HOME/Library/Application Support/wa-mirror}"
  pointer="$data_dir/repo_path"
  [ -f "$pointer" ] || fail "no wa-mirror repository with a .venv next to the plugin and no $pointer"
  repo=""
  { IFS= read -r repo < "$pointer"; } 2>/dev/null || true
  [ -n "$repo" ] || fail "$pointer is empty or unreadable"
  case "$repo" in
    /*) ;;
    *) fail "$pointer does not hold an absolute path" ;;
  esac
  usable "$repo" || fail "$repo (from $pointer) is not the wa-mirror repository with a .venv"
fi

exec "$uv" run --project "$repo" --frozen --no-sync wamirror serve
