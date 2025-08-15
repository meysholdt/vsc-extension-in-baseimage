# =========================
# Stage 1: build extensions
# =========================
FROM ubuntu:22.04 AS extbuilder
ENV DEBIAN_FRONTEND=noninteractive

# Install VS Code CLI (headless usage only) in the builder stage
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg \
 && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends code \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod

USER gitpod

# Copy your .vsix files into the builder
# Put them next to this Dockerfile under ./extensions/
COPY *.vsix /tmp/vsix/

# Use the VS Code CLI to expand/install each VSIX into /out/extensions
RUN mkdir -p /home/gitpod/.vscode-server/extensions/ \
 && set -eux; \
    for f in /tmp/vsix/*.vsix; do \
      [ -e "$f" ] || continue; \
      code --install-extension "$f" \
           --extensions-dir /home/gitpod/.vscode-server/extensions/ \
           --force; \
    done \
 && code --list-extensions --show-versions --extensions-dir /home/gitpod/.vscode-server/extensions/ || true

# =========================
# Stage 2: final image
# =========================
FROM gitpod/workspace-full

ENV rebuild=4

USER gitpod

COPY --from=extbuilder --chown=gitpod:gitpod /home/gitpod/.vscode-server/extensions/ /home/gitpod/.vscode-server/extensions/

RUN mkdir /home/gitpod/extensions
COPY *.vsix /home/gitpod/extensions
COPY install-vsix.sh /home/gitpod/extensions/install-vsix.sh
COPY 110-vsix /home/gitpod/.bashrc.d/110-vsix