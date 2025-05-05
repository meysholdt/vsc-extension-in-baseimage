#!/usr/bin/env bash

# Location for the installer log
LOGFILE="/var/log/vsix-installer.log"

echo "[Info] VSIX installer log: $LOGFILE"

# Redirect all output (stdout and stderr) to the log file
exec >>"$LOGFILE" 2>&1

# Allow script to continue on errors but capture failures via ERR trap
set +e
set -o pipefail

trap 'echo "[Error] Command \"$BASH_COMMAND\" failed with exit code $?"' ERR

# Helper to timestamp logs
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting VSIX installation"

# Check for 'code' CLI
if ! command -v code >/dev/null 2>&1; then
  log "[Error] 'code' CLI not found in PATH."
else
  # Load installed extensions into a lowercase array
  readarray -t INSTALLED < <(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

  shopt -s nullglob
  for vsix in /home/gitpod/extensions/*.vsix; do
    fname=$(basename "$vsix")
    base=${fname%.vsix}
    base=${base,,}

    log "Checking $fname"

    # Determine if any installed extension ID prefixes the VSIX basename
    skip=false
    for id in "${INSTALLED[@]}"; do
      [[ "$base" == "$id"* ]] && { skip=true; break; }
    done

    if $skip; then
      log "Skipping $base (already installed)"
    else
      log "Installing $fname"
      code --install-extension "$vsix"
      log "Installed $base"
    fi
  done
  shopt -u nullglob
fi

log "Completed VSIX installation"
exit 0
