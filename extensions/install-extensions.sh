#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure 'code' is available
if ! command -v code &>/dev/null; then
  echo "❌ 'code' CLI not found in PATH." >&2
  exit 1
fi

# 2) Read installed extension IDs (lowercase) into an array
mapfile -t INSTALLED < <(code --list-extensions)

# Helper: return 0 if any installed ID is a prefix of the given name
is_installed_vsix() {
  local base="$1"
  for id in "${INSTALLED[@]}"; do
    if [[ "$base" == "$id"* ]]; then
      return 0
    fi
  done
  return 1
}

# 3) Loop over all .vsix files
shopt -s nullglob
for vsix in /home/gitpod/extensions/*.vsix; do
  fname="$(basename "$vsix")"
  base="${fname%.vsix}"
  base="${base,,}"  # lowercase to match INSTALLED

  echo "🔍 Checking VSIX: $fname"

  if is_installed_vsix "$base"; then
    echo "   ✔ Already covered by installed extension (prefix match), skipping."
  else
    echo "   ➕ Installing: $fname"
    code --install-extension "$vsix"
  fi
done
shopt -u nullglob

echo "✅ Done."