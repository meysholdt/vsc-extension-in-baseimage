# Preinstalling VS Code Extensions in a Gitpod Base Image

This example shows **how to bake VS Code extensions into a custom Gitpod base image** and install them automatically at runtime—*without* touching any per-repo `.gitpod.yml`.

---

## The Challenge

1. **Extension directory is a runtime mount**
   Gitpod (OpenVSCode‑Server) installs extensions into:

   ```
   /workspace/.vscode-remote/extensions
   ```

   That path is provided as a **mount** only *after* the workspace starts, so a Docker image build cannot place files there directly.

3. **Performance on shell startup**
   We want to run installation logic automatically via a `.bashrc` hook—but since `.bashrc` runs on *every* new terminal, the script must be fast and idempotent (no re‑installs).

---

## How This Example Works

1. **VSIX files in the base image**
   All desired `.vsix` packages are shipped as part of the base image in:

   ```
   /home/gitpod/extensions/
   ```

2. **`install-vsix.sh` script**
   * Runs when bash terminals start via `/home/gitpod/.bashrc.d/110-vsix`
   * Captures the current list of installed extensions via `code --list-extensions`.
   * Scans `/home/gitpod/extensions/*.vsix`, lowercases each filename, and checks if *any* installed ID is a prefix.
   * Calls `code --install-extension` only for those not already present.
   * Logs all output (and any errors) to `/home/gitpod/extensions/vsix-installer.log`.

4. **Idempotency & Speed**
   By checking for prefix matches in the installed list, the script avoids redundant `code --install-extension` calls—fast even if you open dozens of terminals.

## License

This example is released under the MIT License. Feel free to adapt it for your own stacks!
