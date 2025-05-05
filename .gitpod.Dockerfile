FROM gitpod/workspace-full

ENV rebuild=4

USER gitpod

RUN mkdir /home/gitpod/extensions
COPY *.vsix /home/gitpod/extensions
COPY install-vsix.sh /home/gitpod/extensions/install-vsix.sh
COPY 110-vsix /home/gitpod/.bashrc.d/110-vsix