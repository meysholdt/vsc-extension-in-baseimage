#!/usr/bin/env bash
set -euo pipefail

# Where to write all logs
LOGFILE="/home/gitpod/extensions/vsix-installer.log"

# Hint logfile location to the user
echo "[Info] VSIX installer log: ${LOGFILE}"

# Redirect all subsequent output to LOGFILE
exec >"${LOGFILE}" 2>&1

# Ensure 'code' CLI is available
if ! command -v code &>/dev/null; then
  echo "[Error] 'code' CLI not found in PATH."
  exit 1
fi

# Load installed extensions into a lowercase array
readarray -t INSTALLED < <(code --list-extensions | tr '[:upper:]' '[:lower:]')

# Check if any installed ID is a prefix of VSIX basename
is_installed_vsix() {
  local base="$1"
  for id in "${INSTALLED[@]}"; do
    [[ "$base" == "$id"* ]] && return 0
  done
  return 1
}

# Process each VSIX in the extensions directory
echo "[Start] $(date '+%Y-%m-%d %H:%M:%S') - Beginning VSIX installation"
for vsix in /home/gitpod/extensions/*.vsix; do
  [[ -e "$vsix" ]] || continue
  fname=$(basename "${vsix}")
  base=${fname%.vsix}
  base=${base,,}  # to lowercase

  echo "[Check] ${fname}"
  if is_installed_vsix "${base}"; then
    echo "[Skip] ${base} already installed"
  else
    echo "[Install] Installing ${fname}"
    code --install-extension "${vsix}"
    echo "[Done] ${base} installed"
  fi
  echo
 done

echo "[Complete] $(date '+%Y-%m-%d %H:%M:%S') - All VSIX files processed"
