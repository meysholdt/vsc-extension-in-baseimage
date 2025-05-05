#!/usr/bin/env bash

# install-vsix.sh — installs any .vsix not already present, with minimal logging

# grab installed IDs (lowercase)
readarray -t INSTALLED < <(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

shopt -s nullglob
for vsix in /home/gitpod/extensions/*.vsix; do
  base=$(basename "$vsix" .vsix)
  id=${base,,}

  # detect if any installed ID prefixes this one
  skip=false
  for e in "${INSTALLED[@]}"; do
    [[ $id == "$e"* ]] && { skip=true; break; }
  done

  if $skip; then
    echo "[Skip]    $id"
  else
    echo "[Install] $id"
    code --install-extension "$vsix"
  fi
done
shopt -u nullglob